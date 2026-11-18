import 'dart:async';
import 'dart:typed_data';

import 'package:domain_extention/core/log/i_log_service.dart';
import 'package:domain_extention/features/assistant/domain/entity/assistant_page_state_enum.dart';
import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';
import 'package:domain_extention/features/assistant/domain/parser/i_assistant_reply_parser.dart';
import 'package:domain_extention/features/assistant/domain/usecase/i_answer_message_usecase.dart';
import 'package:domain_extention/features/assistant/domain/usecase/i_send_message_usecase.dart';
import 'package:domain_extention/features/character_stage/domain/service/i_character_animation_controller.dart';
import 'package:domain_extention/features/conversation/domain/repository/i_conversation_repository.dart';
import 'package:domain_extention/features/listening/domain/entity/speech_chunk.dart';
import 'package:domain_extention/features/listening/domain/repository/i_speech_repository.dart';
import 'package:domain_extention/features/listening/domain/usecase/i_open_permission_settings_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/i_start_session_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/i_stop_session_usecase.dart';
import 'package:domain_extention/features/voice/domain/entity/playback_end.dart';
import 'package:domain_extention/features/voice/domain/entity/playback_intent.dart';
import 'package:domain_extention/features/voice/domain/entity/voice_playback_status.dart';
import 'package:domain_extention/features/voice/domain/repository/i_voice_playback.dart';
import 'package:domain_extention/features/voice/domain/usecase/i_toggle_playback_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'assistant_page_state.dart';

class AssistantPageCubit extends Cubit<AssistantPageState> {
  AssistantPageCubit({
    required ISendMessageUsecase sendMessage,
    required IAnswerMessageUsecase answerMessage,
    required IStartSessionUsecase startSession,
    required IStopSessionUsecase stopSession,
    required ITogglePlaybackUsecase togglePlayback,
    required IOpenPermissionSettingsUsecase openPermissionSettings,
    required ISpeechRepository speechRepository,
    required IVoicePlayback playback,
    required IAssistantReplyParser replyParser,
    required ICharacterAnimationController animationController,
    required IConversationRepository conversation,
    required String characterId,
    required ILogService log,
  }) : super(const AssistantPageInitial()) {
    _sendMessage = sendMessage;
    _answerMessage = answerMessage;
    _startSession = startSession;
    _stopSession = stopSession;
    _togglePlayback = togglePlayback;
    _openPermissionSettings = openPermissionSettings;
    _speechRepository = speechRepository;
    _playback = playback;
    _replyParser = replyParser;
    _animationController = animationController;
    _conversation = conversation;
    _characterId = characterId;
    _log = log;
    unawaited(loadHistory());
  }

  late final ISendMessageUsecase _sendMessage;
  late final IAnswerMessageUsecase _answerMessage;
  late final IStartSessionUsecase _startSession;
  late final IStopSessionUsecase _stopSession;
  late final ITogglePlaybackUsecase _togglePlayback;
  late final IOpenPermissionSettingsUsecase _openPermissionSettings;
  late final ISpeechRepository _speechRepository;
  late final IVoicePlayback _playback;
  late final IAssistantReplyParser _replyParser;
  late final ICharacterAnimationController _animationController;
  late final IConversationRepository _conversation;
  late final String _characterId;
  late final ILogService _log;

  StreamSubscription<SpeechChunk>? _transcripts;
  StreamSubscription<double>? _levels;
  StreamSubscription<VoicePlaybackStatus>? _playbackStatus;

  int _turn = 0;
  int _outputToken = 0;
  int _sendTicket = 0;
  int _inFlightTicket = 0;
  String? _inFlightText;
  bool _sessionStarted = false;
  Future<void>? _sessionStartInFlight;
  DateTime? _lastVoiceLevelUpdate;
  DateTime? _lastPartialTextUpdate;
  DateTime? _lastAssistantTextUpdate;
  bool _outputActive = false;
  Future<void> _microphoneTransition = Future<void>.value();
  int _positionBucket = -1;
  bool _isCompleted = false;
  bool _historyLoaded = false;
  bool _historyLoading = false;

  Future<void> loadHistory() async {
    if (_historyLoaded || _historyLoading) {
      return;
    }
    _historyLoading = true;
    try {
      final history = await _conversation.loadHistory(
        characterId: _characterId,
      );
      if (isClosed) {
        return;
      }
      _historyLoaded = true;
      if (history.isEmpty || state.messages.isNotEmpty) {
        return;
      }
      emit(state.copyWith(messages: history));
    } catch (error, stackTrace) {
      _log.error(
        'history load failed',
        tag: 'conversation',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _historyLoading = false;
    }
  }

  Future<void> startSession({bool requestIfNeeded = false}) {
    if (_sessionStarted) {
      return Future<void>.value();
    }
    final pending = _sessionStartInFlight;
    if (pending != null) {
      return pending;
    }
    final run = _startSessionInternal(requestIfNeeded: requestIfNeeded)
        .catchError(
          (Object error, StackTrace stackTrace) {
            _log.error(
              'session start failed',
              tag: 'voice',
              error: error,
              stackTrace: stackTrace,
            );
            if (!isClosed) {
              emit(state.copyWith(isConnecting: false, isError: true));
            }
          },
        );
    _sessionStartInFlight = run;
    return run.whenComplete(() {
      if (identical(_sessionStartInFlight, run)) {
        _sessionStartInFlight = null;
      }
    });
  }

  Future<void> _startSessionInternal({required bool requestIfNeeded}) async {
    emit(state.copyWith(isConnecting: true, isError: false));
    unawaited(loadHistory());

    _playbackStatus ??= _playback.status.listen(_onPlaybackStatus);

    var permission = await _speechRepository.permissionStatus();
    _log.info(
      'permission microphone=${permission.microphone} speech=${permission.speech} '
      'speechStatus=${permission.speechStatus} hostedByFlutter=${permission.hostedByFlutter}',
      tag: 'voice',
    );
    if (!permission.isGranted && requestIfNeeded) {
      await _speechRepository.requestPermission();
      permission = await _speechRepository.permissionStatus();
      _log.info(
        'after request microphone=${permission.microphone} speech=${permission.speech} '
        'speechStatus=${permission.speechStatus}',
        tag: 'voice',
      );
    }
    if (!permission.isGranted) {
      _log.warn(
        'permission missing microphone=${permission.microphone} speech=${permission.speech}',
        tag: 'voice',
      );
      emit(
        state.copyWith(
          isConnecting: false,
          needsPermission: true,
          hasMicrophone: permission.microphone,
          hasSpeech: permission.speech,
          hostedByFlutter: permission.hostedByFlutter,
        ),
      );
      return;
    }

    if (_outputActive) {
      await _cancelOutput();
    }
    final ready = await _startSession();
    if (isClosed) {
      return;
    }
    if (!ready) {
      _log.warn('session start failed', tag: 'voice');
      emit(
        state.copyWith(
          isConnecting: false,
          needsPermission: true,
          isError: true,
          hasMicrophone: permission.microphone,
          hasSpeech: permission.speech,
          hostedByFlutter: permission.hostedByFlutter,
        ),
      );
      return;
    }

    _sessionStarted = true;
    _log.info('session started', tag: 'voice');
    _transcripts ??= _speechRepository.transcripts.listen(_onSpeech);
    _levels ??= _speechRepository.soundLevel.listen(_onSoundLevel);
    emit(
      state.copyWith(
        isConnecting: false,
        state: AssistantPageStateEnum.listening,
        sessionActive: true,
        needsPermission: false,
        hasMicrophone: true,
        hasSpeech: true,
        hostedByFlutter: permission.hostedByFlutter,
        isError: false,
        voiceLevel: 0,
      ),
    );
  }

  void startDialog() {
    unawaited(startSession(requestIfNeeded: true));
  }

  void toggleDialog() {
    unawaited(_toggleDialog());
  }

  Future<void> _toggleDialog() async {
    if (_sessionStarted) {
      await stopDialog();
      return;
    }
    await startSession(requestIfNeeded: true);
  }

  Future<void> stopDialog() async {
    _sessionStarted = false;
    _turn++;
    _sendTicket++;
    _inFlightText = null;
    _inFlightTicket = 0;
    _animationController.stop();
    await _cancelOutput();
    await _microphoneTransition;
    if (isClosed) {
      return;
    }
    await _stopSession();
    if (isClosed) {
      return;
    }
    _log.info('session stopped', tag: 'voice');
    emit(
      state.copyWith(
        sessionActive: false,
        partialText: '',
        isPlaying: false,
        voiceLevel: 0,
        state: state.state == AssistantPageStateEnum.listening
            ? AssistantPageStateEnum.idle
            : state.state,
      ),
    );
  }

  void requestPermission() {
    startDialog();
  }

  Future<void> openPermissionSettings() {
    final target = state.hasSpeech ? 'microphone' : 'speech';
    return _openPermissionSettings(target: target);
  }

  Future<void> retryPermission() async {
    final permission = await _speechRepository.permissionStatus();
    if (!permission.isGranted) {
      if (state.needsPermission) {
        emit(
          state.copyWith(
            hasMicrophone: permission.microphone,
            hasSpeech: permission.speech,
            hostedByFlutter: permission.hostedByFlutter,
          ),
        );
      }
      return;
    }
    if (state.needsPermission || _sessionStarted) {
      await startSession();
    }
  }

  Future<void> sendMessage(String message) async {
    final text = message.trim();
    if (text.isEmpty) {
      return;
    }
    if (_inFlightText == text) {
      return;
    }

    unawaited(loadHistory());

    final ticket = ++_sendTicket;
    _inFlightText = text;
    _inFlightTicket = ticket;
    final turn = ++_turn;
    try {
      _animationController.stop();
      await _cancelOutput();
      if (turn != _turn || isClosed) {
        return;
      }
      await _deliver(text, turn);
    } finally {
      if (_inFlightTicket == ticket) {
        _inFlightText = null;
        _inFlightTicket = 0;
      }
    }
  }

  Future<void> _deliver(String text, int turn) async {
    final history = [
      for (final item in state.messages)
        if (!(item.role == 'assistant' &&
            item.busy &&
            item.text.trim().isEmpty))
          item.busy ? item.copyWith(busy: false) : item,
    ];
    emit(
      state.copyWith(
        messages: [
          ...history,
          ChatMessage(role: 'user', text: text),
          const ChatMessage(role: 'assistant', text: '', busy: true),
        ],
        state: AssistantPageStateEnum.sending,
        partialText: '',
        isError: false,
        isPlaying: false,
        playingMessageIndex: null,
      ),
    );
    unawaited(_persist(ChatMessage(role: 'user', text: text)));

    final speechQueue = StreamController<String>();
    final audioSegments = <Uint8List>[];
    final speechBuffer = StringBuffer();
    var queuedText = '';
    final speechPlayback = _playSpeechQueue(
      speechQueue.stream,
      audioSegments,
      turn,
    );
    try {
      final elapsed = Stopwatch()..start();
      _log.info('request turn=$turn chars=${text.length}', tag: 'llm');
      var receivedChunk = false;
      var rawReply = '';
      var displayText = '';
      await for (final textSoFar in _sendMessage(
        userText: text,
        history: history,
      )) {
        if (turn != _turn || isClosed) {
          return;
        }
        if (!receivedChunk) {
          receivedChunk = true;
          _log.info(
            'first chunk turn=$turn elapsedMs=${elapsed.elapsedMilliseconds}',
            tag: 'llm',
          );
        }
        rawReply = textSoFar;
        final partial = _replyParser.parse(rawReply);
        if (!partial.emotionResolved) {
          continue;
        }
        displayText = partial.text;
        if (displayText.startsWith(queuedText)) {
          speechBuffer.write(displayText.substring(queuedText.length));
          queuedText = displayText;
          for (final phrase in _drainSpeechBuffer(speechBuffer)) {
            speechQueue.add(phrase);
          }
        }
        _setAssistant(text: displayText, busy: true);
      }
      if (turn != _turn || isClosed) {
        return;
      }
      _log.info(
        'response finished turn=$turn chars=${rawReply.length} '
        'elapsedMs=${elapsed.elapsedMilliseconds}',
        tag: 'llm',
      );
      final payload = _replyParser.parse(rawReply);
      displayText = payload.text.trim();
      if (displayText.isEmpty) {
        _setAssistant(text: '', busy: false);
        emit(state.copyWith(isError: true, state: _listeningOrIdle));
        return;
      }
      if (payload.cue != null) {
        _animationController.applyCue(payload.cue!);
      }
      if (displayText.startsWith(queuedText)) {
        speechBuffer.write(displayText.substring(queuedText.length));
        queuedText = displayText;
      }
      for (final phrase in _drainSpeechBuffer(speechBuffer, flush: true)) {
        speechQueue.add(phrase);
      }
      _setAssistant(text: displayText, busy: true);
      unawaited(_persist(ChatMessage(role: 'assistant', text: displayText)));
      await speechQueue.close();
      await speechPlayback;
      if (turn != _turn || isClosed) {
        return;
      }
      _setAssistant(
        text: displayText,
        audioSegments: List<Uint8List>.unmodifiable(audioSegments),
        busy: false,
      );
      emit(
        state.copyWith(
          state: AssistantPageStateEnum.answer,
          playingMessageIndex: audioSegments.isEmpty
              ? null
              : state.messages.length - 1,
          isError: state.isError,
        ),
      );
    } catch (error, stackTrace) {
      if (turn != _turn || isClosed) {
        return;
      }
      _log.error(
        'llm failed',
        tag: 'llm',
        error: error,
        stackTrace: stackTrace,
      );
      _clearBusy();
      emit(state.copyWith(isError: true, state: _listeningOrIdle));
    } finally {
      if (!speechQueue.isClosed) {
        await speechQueue.close();
      }
      await speechPlayback;
    }
  }

  List<String> _drainSpeechBuffer(
    StringBuffer buffer, {
    bool flush = false,
  }) {
    final phrases = <String>[];
    var remaining = buffer.toString();
    final sentenceEnd = RegExp(r'[.!?…]+(?:[”"»)]*)\s+|\n+');
    while (remaining.isNotEmpty) {
      final boundary = sentenceEnd.firstMatch(remaining);
      var splitAt = boundary?.end ?? -1;
      if (splitAt < 0 && remaining.length >= 140) {
        splitAt = remaining.lastIndexOf(' ', 140);
        if (splitAt < 80) {
          splitAt = -1;
        }
      }
      if (splitAt < 0 && flush) {
        splitAt = remaining.length;
      }
      if (splitAt < 0) {
        break;
      }
      final phrase = remaining.substring(0, splitAt).trim();
      if (phrase.isNotEmpty) {
        phrases.add(phrase);
      }
      remaining = remaining.substring(splitAt).trimLeft();
    }
    buffer
      ..clear()
      ..write(remaining);
    return phrases;
  }

  Future<void> _playSpeechQueue(
    Stream<String> phrases,
    List<Uint8List> audioSegments,
    int turn,
  ) async {
    final readyAudio = StreamController<Uint8List>();
    final synthesis = () async {
      try {
        await for (final phrase in phrases) {
          if (turn != _turn || isClosed) {
            break;
          }
          try {
            final elapsed = Stopwatch()..start();
            _log.info('request turn=$turn chars=${phrase.length}', tag: 'tts');
            final audio = await _answerMessage(phrase);
            _log.info(
              'audio received turn=$turn bytes=${audio.length} '
              'elapsedMs=${elapsed.elapsedMilliseconds}',
              tag: 'tts',
            );
            if (turn != _turn || isClosed) {
              break;
            }
            audioSegments.add(audio);
            _setAssistant(
              audioSegments: List<Uint8List>.unmodifiable(audioSegments),
              busy: true,
            );
            emit(
              state.copyWith(
                state: AssistantPageStateEnum.answer,
                playingMessageIndex: state.messages.length - 1,
              ),
            );
            readyAudio.add(audio);
          } catch (error, stackTrace) {
            if (turn != _turn || isClosed) {
              break;
            }
            _log.error(
              'tts chunk failed',
              tag: 'tts',
              error: error,
              stackTrace: stackTrace,
            );
            emit(state.copyWith(isError: true));
          }
        }
      } finally {
        await readyAudio.close();
      }
    }();

    await for (final audio in readyAudio.stream) {
      if (turn != _turn || isClosed) {
        break;
      }
      await _playOwned(audio, turn: turn);
    }
    await synthesis;
  }

  Future<void> togglePlayback(int messageIndex) async {
    final audio = _audioSegmentsAt(messageIndex);
    final intent = _togglePlayback(
      hasAudio: audio != null,
      isCurrentClip: state.playingMessageIndex == messageIndex,
      isPlaying: state.isPlaying,
      isCompleted: _isCompleted,
    );
    if (intent == null || audio == null) {
      return;
    }

    switch (intent) {
      case PlaybackIntent.pause:
        await _playback.pause();
      case PlaybackIntent.resume:
        _outputActive = true;
        await _playback.resume();
      case PlaybackIntent.play:
        _isCompleted = false;
        emit(
          state.copyWith(
            playingMessageIndex: messageIndex,
            isError: false,
          ),
        );
        await _playSegments(audio, turn: _turn);
    }
  }

  Future<void> replay(int messageIndex) async {
    final audio = _audioSegmentsAt(messageIndex);
    if (audio == null) {
      return;
    }
    _isCompleted = false;
    emit(
      state.copyWith(
        playingMessageIndex: messageIndex,
        isError: false,
      ),
    );
    await _playSegments(audio, turn: _turn);
  }

  Future<void> _playSegments(
    List<Uint8List> segments, {
    required int turn,
  }) async {
    for (final segment in segments) {
      if (turn != _turn || isClosed) {
        return;
      }
      await _playOwned(segment, turn: turn);
    }
  }

  void _onSoundLevel(double level) {
    if (isClosed) {
      return;
    }
    if (!_sessionStarted || _outputActive) {
      if (state.voiceLevel != 0) {
        emit(state.copyWith(voiceLevel: 0));
      }
      return;
    }
    final normalized = (level / 10).clamp(0.0, 1.0);
    if ((normalized - state.voiceLevel).abs() < 0.04) {
      return;
    }
    final now = DateTime.now();
    if (_lastVoiceLevelUpdate != null &&
        now.difference(_lastVoiceLevelUpdate!) <
            const Duration(milliseconds: 100)) {
      return;
    }
    _lastVoiceLevelUpdate = now;
    emit(state.copyWith(voiceLevel: normalized));
  }

  void _onSpeech(SpeechChunk chunk) {
    if (isClosed || !_sessionStarted || _outputActive) {
      return;
    }

    final text = chunk.text.trim();
    if (text.isEmpty) {
      return;
    }

    if (!chunk.isFinal) {
      final now = DateTime.now();
      if (_lastPartialTextUpdate != null &&
          now.difference(_lastPartialTextUpdate!) <
              const Duration(milliseconds: 100)) {
        return;
      }
      _lastPartialTextUpdate = now;
    }
    emit(state.copyWith(partialText: text));
    if (!chunk.isFinal) {
      return;
    }

    _log.info('send from voice chars=${text.length}', tag: 'voice');
    emit(state.copyWith(partialText: ''));
    unawaited(sendMessage(text));
  }

  void _onPlaybackStatus(VoicePlaybackStatus status) {
    if (isClosed) {
      return;
    }
    final playing = _outputActive && status.isPlaying;
    final bucket = status.position.inMilliseconds ~/ 100;
    final changed =
        playing != state.isPlaying ||
        status.isCompleted != _isCompleted ||
        status.duration != state.playbackDuration ||
        bucket != _positionBucket;
    if (!changed) {
      return;
    }

    _isCompleted = status.isCompleted;
    _positionBucket = bucket;
    emit(
      state.copyWith(
        isPlaying: playing,
        playbackPosition: status.position,
        playbackDuration: status.duration,
      ),
    );
  }

  Future<void> _playOwned(
    Uint8List audio, {
    required int turn,
  }) async {
    final token = ++_outputToken;
    _outputActive = true;
    _isCompleted = false;
    if (state.voiceLevel != 0 || state.partialText.isNotEmpty) {
      emit(state.copyWith(voiceLevel: 0, partialText: ''));
    }
    PlaybackEnd? end;
    try {
      await _sessionStartInFlight;
      await _setMicrophonePaused(true, token);
      if (token == _outputToken && turn == _turn && !isClosed) {
        final elapsed = Stopwatch()..start();
        _log.info('start turn=$turn bytes=${audio.length}', tag: 'playback');
        end = await _playback.play(audio);
        _log.info(
          'finished turn=$turn result=${end.name} '
          'elapsedMs=${elapsed.elapsedMilliseconds}',
          tag: 'playback',
        );
      }
    } finally {
      await _restoreMicrophone(token);
    }
    if (token != _outputToken) {
      return;
    }

    _outputActive = false;
    if (isClosed) {
      return;
    }
    final failed = end == PlaybackEnd.failed;
    _isCompleted = end == PlaybackEnd.completed;
    if (failed) {
      _log.warn('playback failed', tag: 'voice');
    }
    emit(
      state.copyWith(
        isPlaying: false,
        isError: failed,
        state: _listeningOrIdle,
      ),
    );
  }

  Future<void> _setMicrophonePaused(bool paused, int token) {
    return _microphoneTransition = _microphoneTransition.then((_) async {
      if (!_sessionStarted || isClosed || token != _outputToken) {
        return;
      }
      try {
        if (paused) {
          await _speechRepository.pause();
        } else {
          await _speechRepository.resume();
        }
      } catch (error, stackTrace) {
        _log.error(
          'microphone transition failed',
          tag: 'voice',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
  }

  Future<void> _restoreMicrophone(int token) async {
    if (token != _outputToken || !_outputActive || !_sessionStarted) {
      return;
    }
    // Let the last syllable clear the speaker before opening the microphone.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (token == _outputToken) {
      _outputActive = false;
      await _setMicrophonePaused(false, token);
    }
  }

  Future<void> _cancelOutput() async {
    final token = ++_outputToken;
    await _playback.stop();
    await _restoreMicrophone(token);
    if (token == _outputToken) {
      _outputActive = false;
    }
    if (!isClosed && token == _outputToken) {
      emit(
        state.copyWith(
          isPlaying: false,
          playingMessageIndex: null,
          voiceLevel: 0,
        ),
      );
    }
  }

  void _setAssistant({
    String? text,
    Uint8List? audio,
    List<Uint8List>? audioSegments,
    bool? busy,
  }) {
    if (state.messages.isEmpty) {
      return;
    }
    final messages = [...state.messages];
    final last = messages.last;
    if (last.role != 'assistant') {
      return;
    }
    final nextBusy = busy ?? last.busy;
    if (nextBusy && text != null) {
      final now = DateTime.now();
      if (_lastAssistantTextUpdate != null &&
          now.difference(_lastAssistantTextUpdate!) <
              const Duration(milliseconds: 80)) {
        return;
      }
      _lastAssistantTextUpdate = now;
    }
    messages[messages.length - 1] = last.copyWith(
      text: text ?? last.text,
      audio: audio ?? last.audio,
      audioSegments: audioSegments ?? last.audioSegments,
      busy: busy ?? last.busy,
    );
    emit(
      state.copyWith(
        messages: messages,
        state: AssistantPageStateEnum.answer,
      ),
    );
  }

  void _clearBusy() {
    if (state.messages.isEmpty) {
      return;
    }
    final messages = [...state.messages];
    final last = messages.last;
    if (last.role != 'assistant' || !last.busy) {
      return;
    }
    messages[messages.length - 1] = last.copyWith(busy: false);
    emit(state.copyWith(messages: messages));
  }

  AssistantPageStateEnum get _listeningOrIdle => _sessionStarted
      ? AssistantPageStateEnum.listening
      : AssistantPageStateEnum.idle;

  List<Uint8List>? _audioSegmentsAt(int messageIndex) {
    if (messageIndex < 0 || messageIndex >= state.messages.length) {
      return null;
    }
    final message = state.messages[messageIndex];
    if (message.audioSegments?.isNotEmpty ?? false) {
      return message.audioSegments;
    }
    final audio = message.audio;
    return audio == null ? null : <Uint8List>[audio];
  }

  Future<void> _persist(ChatMessage message) async {
    try {
      await _conversation.saveMessage(
        characterId: _characterId,
        message: message,
      );
    } catch (error, stackTrace) {
      _log.error(
        'message save failed',
        tag: 'conversation',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> close() async {
    _sessionStarted = false;
    _turn++;
    _outputToken++;
    await _transcripts?.cancel();
    await _levels?.cancel();
    await _playbackStatus?.cancel();
    await _microphoneTransition;
    await _stopSession();
    await _playback.stop();
    return super.close();
  }
}
