import 'dart:async';
import 'dart:typed_data';

import 'package:domain_extention/core/log/log_service.dart';
import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';
import 'package:domain_extention/features/assistant/domain/parser/assistant_reply_parser.dart';
import 'package:domain_extention/features/assistant/domain/usecase/i_answer_message_usecase.dart';
import 'package:domain_extention/features/assistant/domain/usecase/i_send_message_usecase.dart';
import 'package:domain_extention/features/assistant/presentation/cubit/assistant_page_cubit.dart';
import 'package:domain_extention/features/character_stage/presentation/cubit/character_animation_cubit.dart';
import 'package:domain_extention/features/conversation/domain/repository/i_conversation_repository.dart';
import 'package:domain_extention/features/listening/domain/entity/speech_chunk.dart';
import 'package:domain_extention/features/listening/domain/entity/speech_permission.dart';
import 'package:domain_extention/features/listening/domain/repository/i_speech_repository.dart';
import 'package:domain_extention/features/listening/domain/usecase/open_permission_settings_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/pause_session_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/resume_session_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/start_session_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/stop_session_usecase.dart';
import 'package:domain_extention/features/voice/domain/entity/playback_end.dart';
import 'package:domain_extention/features/voice/domain/entity/voice_playback_status.dart';
import 'package:domain_extention/features/voice/domain/repository/i_voice_playback.dart';
import 'package:domain_extention/features/voice/domain/usecase/toggle_playback_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('повторное нажатие останавливает микрофон', () async {
    final speech = _SpeechFake();
    final cubit = _cubit(speech: speech, playback: _PlaybackFake());

    cubit.toggleDialog();
    await cubit.stream.firstWhere((state) => state.sessionActive);
    expect(speech.trace.where((event) => event == 'start'), hasLength(1));

    cubit.toggleDialog();
    await cubit.stream.firstWhere((state) => !state.sessionActive);
    expect(speech.trace.where((event) => event == 'stop'), hasLength(1));
    expect(cubit.state.partialText, isEmpty);

    speech.transcriptsController.add(
      const SpeechChunk(text: 'после стопа', isFinal: true),
    );
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.messages, isEmpty);

    await cubit.close();
  });

  test('финальный текст один раз попадает в чат и в озвучку', () async {
    final trace = <String>[];
    final speech = _SpeechFake(trace: trace);
    final playback = _PlaybackFake(trace: trace);
    final answer = _AnswerFake();
    final cubit = _cubit(
      speech: speech,
      playback: playback,
      answer: answer,
      send: _SendFake(['При', 'Привет.', 'Привет. Как дела?']),
    );
    cubit.toggleDialog();
    await cubit.stream.firstWhere((state) => state.sessionActive);

    final gate = Completer<void>();
    playback.nextHold = gate;
    final pending = cubit.sendMessage('вопрос');
    while (!playback.trace.contains('play')) {
      await Future<void>.delayed(Duration.zero);
    }

    speech.transcriptsController.add(
      const SpeechChunk(text: 'это мой голос из динамика', isFinal: true),
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      cubit.state.messages.where((message) => message.role == 'user'),
      hasLength(1),
    );

    gate.complete();
    await pending;

    expect(answer.spoken, ['Привет. Как дела?']);
    final assistant = cubit.state.messages.last;
    expect(assistant.role, 'assistant');
    expect(assistant.text, 'Привет. Как дела?');
    expect(assistant.busy, isFalse);
    expect(assistant.audio, playback.played.single);
    expect(cubit.state.isError, isFalse);
    expect(
      trace.indexOf('pause'),
      lessThan(trace.indexOf('play')),
    );
    expect(
      trace.indexOf('play'),
      lessThan(trace.indexOf('resume')),
    );

    await cubit.close();
  });

  test('ошибка озвучки оставляет текст в чате', () async {
    final answer = _AnswerFake()..fail = true;
    final playback = _PlaybackFake();
    final cubit = _cubit(
      speech: _SpeechFake(),
      playback: playback,
      answer: answer,
      send: _SendFake(['Готовый ответ']),
    );

    await cubit.sendMessage('вопрос');

    expect(cubit.state.messages.last.text, 'Готовый ответ');
    expect(cubit.state.messages.last.audio, isNull);
    expect(cubit.state.isError, isTrue);
    expect(playback.played, isEmpty);

    await cubit.close();
  });

  test('ошибка плеера не стирает ответ', () async {
    final playback = _PlaybackFake()..end = PlaybackEnd.failed;
    final cubit = _cubit(
      speech: _SpeechFake(),
      playback: playback,
      send: _SendFake(['Фраза целиком']),
    );

    await cubit.sendMessage('вопрос');

    expect(cubit.state.messages.last.text, 'Фраза целиком');
    expect(cubit.state.messages.last.audio, isNotNull);
    expect(cubit.state.isError, isTrue);
    expect(cubit.state.isPlaying, isFalse);

    await cubit.close();
  });

  test('выключение микрофона во время озвучки останавливает плеер', () async {
    final speech = _SpeechFake();
    final playback = _PlaybackFake();
    final cubit = _cubit(
      speech: speech,
      playback: playback,
      send: _SendFake(['Длинная фраза']),
    );
    cubit.toggleDialog();
    await cubit.stream.firstWhere((state) => state.sessionActive);

    final gate = Completer<void>();
    playback.nextHold = gate;
    final pending = cubit.sendMessage('вопрос');
    while (!playback.trace.contains('play')) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(cubit.state.isPlaying, isTrue);

    cubit.toggleDialog();
    await cubit.stream.firstWhere((state) => !state.sessionActive);
    expect(playback.trace, contains('stop'));
    expect(cubit.state.isPlaying, isFalse);
    expect(cubit.state.playingMessageIndex, isNull);

    gate.complete();
    await pending;
    expect(cubit.state.isPlaying, isFalse);

    await cubit.close();
  });

  test('тот же текст после завершения снова отправляется', () async {
    final send = _SendFake(['Раз', 'Раз']);
    final cubit = _cubit(
      speech: _SpeechFake(),
      playback: _PlaybackFake(),
      send: send,
    );

    await cubit.sendMessage('повтор');
    await cubit.sendMessage('повтор');

    expect(
      cubit.state.messages.where((message) => message.role == 'user'),
      hasLength(2),
    );
    expect(send.calls, 2);

    await cubit.close();
  });

  test('эмоция из JSON уходит в анимации, в чат и TTS — только текст', () async {
    final animation = CharacterAnimationCubit();
    final answer = _AnswerFake();
    final cubit = _cubit(
      speech: _SpeechFake(),
      playback: _PlaybackFake(),
      answer: answer,
      animation: animation,
      send: _SendFake([
        '{"emotion":"amused","delay_ms":0}\n',
        '{"emotion":"amused","delay_ms":0}\nНу? Не тяни.',
      ]),
    );

    await cubit.sendMessage('привет');

    expect(cubit.state.messages.last.text, 'Ну? Не тяни.');
    expect(answer.spoken, ['Ну? Не тяни.']);
    expect(animation.current.name, 'amused');
    expect(animation.scheduled, isNull);

    await cubit.close();
    await animation.close();
  });
}

AssistantPageCubit _cubit({
  required _SpeechFake speech,
  required _PlaybackFake playback,
  _SendFake? send,
  _AnswerFake? answer,
  CharacterAnimationCubit? animation,
}) {
  return AssistantPageCubit(
    sendMessage: send ?? _SendFake(const ['Ответ']),
    answerMessage: answer ?? _AnswerFake(),
    startSession: StartSessionUsecase(speech),
    stopSession: StopSessionUsecase(speech),
    pauseSession: PauseSessionUsecase(speech),
    resumeSession: ResumeSessionUsecase(speech),
    togglePlayback: const TogglePlaybackUsecase(),
    openPermissionSettings: OpenPermissionSettingsUsecase(speech),
    speechRepository: speech,
    playback: playback,
    replyParser: const AssistantReplyParser(),
    animationController: animation ?? CharacterAnimationCubit(),
    conversation: const _ConversationFake(),
    characterId: 'sukuna',
    log: const LogService(),
  );
}

class _ConversationFake implements IConversationRepository {
  const _ConversationFake();

  @override
  Future<List<ChatMessage>> loadHistory({required String characterId}) async {
    return const [];
  }

  @override
  Future<void> saveMessage({
    required String characterId,
    required ChatMessage message,
  }) async {}
}

class _SendFake implements ISendMessageUsecase {
  _SendFake(this.parts);

  final List<String> parts;
  var calls = 0;

  @override
  Stream<String> call({
    required String userText,
    List<ChatMessage> history = const [],
  }) async* {
    calls += 1;
    for (final part in parts) {
      yield part;
    }
  }
}

class _AnswerFake implements IAnswerMessageUsecase {
  final spoken = <String>[];
  bool fail = false;
  final bytes = Uint8List.fromList(const [1, 2, 3, 4]);

  @override
  Future<Uint8List> call(String message) async {
    spoken.add(message);
    if (fail) {
      throw StateError('tts');
    }
    return bytes;
  }
}

class _SpeechFake implements ISpeechRepository {
  _SpeechFake({List<String>? trace}) : trace = trace ?? <String>[];

  final transcriptsController = StreamController<SpeechChunk>.broadcast();
  final levelController = StreamController<double>.broadcast();
  final List<String> trace;

  @override
  Stream<SpeechChunk> get transcripts => transcriptsController.stream;

  @override
  Stream<double> get soundLevel => levelController.stream;

  @override
  bool isListening = false;

  @override
  Future<SpeechPermission> permissionStatus() async {
    return const SpeechPermission(microphone: true, speech: true);
  }

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> openPermissionSettings({String target = 'auto'}) async => true;

  @override
  Future<bool> start({String? localeId}) async {
    trace.add('start');
    isListening = true;
    return true;
  }

  @override
  Future<void> pause() async {
    trace.add('pause');
    isListening = false;
  }

  @override
  Future<void> resume() async {
    trace.add('resume');
    isListening = true;
  }

  @override
  Future<void> stop() async {
    trace.add('stop');
    isListening = false;
  }
}

class _PlaybackFake implements IVoicePlayback {
  _PlaybackFake({List<String>? trace}) : trace = trace ?? <String>[];

  final statusController = StreamController<VoicePlaybackStatus>.broadcast();
  final played = <Uint8List>[];
  final List<String> trace;
  PlaybackEnd end = PlaybackEnd.completed;
  Completer<void>? nextHold;
  bool playing = false;

  @override
  Stream<VoicePlaybackStatus> get status => statusController.stream;

  @override
  bool get isPlaying => playing;

  @override
  Future<PlaybackEnd> play(Uint8List bytes) async {
    trace.add('play');
    played.add(bytes);
    playing = true;
    statusController.add(
      const VoicePlaybackStatus(
        isPlaying: true,
        isCompleted: false,
        position: Duration.zero,
        duration: Duration(seconds: 2),
      ),
    );
    final gate = nextHold;
    nextHold = null;
    if (gate != null) {
      await gate.future;
    }
    playing = false;
    statusController.add(
      VoicePlaybackStatus(
        isPlaying: false,
        isCompleted: end == PlaybackEnd.completed,
        position: const Duration(seconds: 2),
        duration: const Duration(seconds: 2),
      ),
    );
    return end;
  }

  @override
  Future<void> pause() async {
    playing = false;
  }

  @override
  Future<void> resume() async {
    playing = true;
  }

  @override
  Future<void> stop() async {
    trace.add('stop');
    playing = false;
  }
}
