import 'dart:async';

import 'package:domain_extention/core/log/i_log_service.dart';
import 'package:domain_extention/core/log/log_service.dart';
import 'package:domain_extention/features/listening/data/datasource/i_speech_to_text_datasource.dart';
import 'package:domain_extention/features/listening/data/datasource/mac_permission_channel.dart';
import 'package:domain_extention/features/listening/domain/entity/speech_chunk.dart';
import 'package:domain_extention/features/listening/domain/entity/speech_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextDatasource implements ISpeechToTextDatasource {
  SpeechToTextDatasource({
    SpeechToText? speech,
    MacPermissionChannel? macPermissions,
    ILogService? log,
  }) : _speech = speech ?? SpeechToText(),
       _macPermissions = macPermissions ?? MacPermissionChannel(),
       _log = log ?? const LogService();

  final SpeechToText _speech;
  final MacPermissionChannel _macPermissions;
  final ILogService _log;
  final _transcripts = StreamController<SpeechChunk>.broadcast();
  final _soundLevel = StreamController<double>.broadcast();

  bool _enabled = false;
  bool _paused = false;
  bool _starting = false;
  bool _useOfflineRecognition = false;
  bool _triedOfflineRecognition = false;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool _restartScheduled = false;
  int _restartAttempts = 0;
  int _silenceRestartAttempts = 0;
  Timer? _restartTimer;
  DateTime? _lastInputLevelLog;
  String? _localeId;
  Future<void>? _listenInFlight;
  Future<bool>? _initializeInFlight;

  static const _tag = 'voice';
  static const _restartDelay = Duration(milliseconds: 900);
  static const _busyDelay = Duration(seconds: 2);

  @override
  Stream<SpeechChunk> get transcripts => _transcripts.stream;

  @override
  Stream<double> get soundLevel => _soundLevel.stream;

  @override
  bool get isListening => _speech.isListening;

  /// Warms the speech service without starting capture or prompting for access.
  Future<void> warmUp() async {
    try {
      if (!await _speech.hasPermission) {
        return;
      }
      if (await _initialize()) {
        _localeId ??= await _resolveLocale();
      }
    } catch (error, stackTrace) {
      _log.warn('speech warm-up failed', tag: _tag);
      _log.debug('$error\n$stackTrace', tag: _tag);
    }
  }

  @override
  Future<SpeechPermission> permissionStatus() async {
    if (_macPermissions.isSupported) {
      final status = await _macPermissions.status();
      _log.info(
        'permission microphone=${status.microphone} speech=${status.speech} '
        'speechStatus=${status.speechStatus} hostedByFlutter=${status.hostedByFlutter}',
        tag: _tag,
      );
      return status;
    }
    final granted = await _speech.hasPermission;
    return SpeechPermission(microphone: granted, speech: granted);
  }

  @override
  Future<bool> hasPermission() async {
    return (await permissionStatus()).isGranted;
  }

  @override
  Future<bool> requestPermission() {
    if (_macPermissions.isSupported) {
      return _macPermissions.request();
    }
    // speech_to_text requests the native microphone (and, on iOS, speech
    // recognition) permissions as part of initialize(). Merely reading
    // hasPermission does not trigger the system prompt on Android or iOS.
    return _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
      options: [SpeechToText.androidNoBluetooth],
    );
  }

  @override
  Future<bool> openPermissionSettings({String target = 'auto'}) {
    if (_macPermissions.isSupported) {
      return _macPermissions.openSettings(target: target);
    }
    return Future<bool>.value(false);
  }

  @override
  Future<bool> start({String? localeId}) async {
    _enabled = true;
    _paused = false;
    _restartAttempts = 0;
    _silenceRestartAttempts = 0;
    _useOfflineRecognition = false;
    _triedOfflineRecognition = false;
    _localeId = localeId ?? _localeId;

    final ready = await _initialize();
    if (!ready) {
      _enabled = false;
      _log.warn('initialize failed', tag: _tag);
      return false;
    }

    _localeId ??= await _resolveLocale();
    _log.info('listening locale=$_localeId', tag: _tag);
    await _listen();
    if (!_speech.isListening && !_restartScheduled) {
      _enabled = false;
      _log.warn('recognizer did not start listening', tag: _tag);
      return false;
    }
    return _enabled;
  }

  Future<bool> _initialize() {
    if (_speech.isAvailable) {
      return Future<bool>.value(true);
    }
    final pending = _initializeInFlight;
    if (pending != null) {
      return pending;
    }
    _log.info('initialize locale=${_localeId ?? 'auto'}', tag: _tag);
    final run = _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
      options: [SpeechToText.androidNoBluetooth],
    );
    _initializeInFlight = run;
    return run.whenComplete(() {
      if (identical(_initializeInFlight, run)) {
        _initializeInFlight = null;
      }
    });
  }

  @override
  Future<void> pause() async {
    if (!_enabled) {
      return;
    }
    _log.info('pause', tag: _tag);
    _paused = true;
    _restartScheduled = false;
    _restartTimer?.cancel();
    final pending = _listenInFlight;
    if (pending != null) {
      await pending;
    }
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }

  @override
  Future<void> resume() async {
    if (!_enabled) {
      return;
    }
    _log.info('resume', tag: _tag);
    _paused = false;
    await _listen();
  }

  @override
  Future<void> stop() async {
    _log.info('stop', tag: _tag);
    _enabled = false;
    _paused = false;
    _restartScheduled = false;
    _restartTimer?.cancel();
    final pending = _listenInFlight;
    if (pending != null) {
      await pending;
    }
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }

  Future<String> _resolveLocale() async {
    final locales = await _speech.locales();
    bool matches(String id) {
      final normalized = id.replaceAll('-', '_').toLowerCase();
      return locales.any(
        (locale) =>
            locale.localeId.replaceAll('-', '_').toLowerCase() == normalized,
      );
    }

    for (final candidate in ['ru_RU', 'ru-RU']) {
      if (matches(candidate)) {
        return locales
            .firstWhere(
              (locale) =>
                  locale.localeId.replaceAll('-', '_').toLowerCase() ==
                  candidate.replaceAll('-', '_').toLowerCase(),
            )
            .localeId;
      }
    }

    return (await _speech.systemLocale())?.localeId ?? 'ru_RU';
  }

  Future<void> _listen() async {
    if (!_enabled || _paused || _starting || _speech.isListening) {
      return;
    }

    _starting = true;
    final run = _startListen();
    _listenInFlight = run;
    try {
      await run;
    } finally {
      if (identical(_listenInFlight, run)) {
        _listenInFlight = null;
      }
      _starting = false;
    }
  }

  Future<void> _startListen() async {
    final elapsed = Stopwatch()..start();
    var receivedAudioLevel = false;
    _lastInputLevelLog = null;
    _log.info(
      'capture requested locale=$_localeId onDevice=$_useOfflineRecognition',
      tag: _tag,
    );
    try {
      await _speech.listen(
        onResult: (result) {
          if (!_enabled || _paused) {
            return;
          }
          final text = result.recognizedWords.trim();
          if (text.isEmpty) {
            return;
          }
          _restartAttempts = 0;
          _silenceRestartAttempts = 0;
          _log.info(
            'recognized final=${result.finalResult} chars=${text.length} '
            'elapsedMs=${elapsed.elapsedMilliseconds}',
            tag: _tag,
          );
          _transcripts.add(
            SpeechChunk(text: text, isFinal: result.finalResult),
          );
        },
        onSoundLevelChange: (level) {
          if (!_enabled || _paused || _soundLevel.isClosed) {
            return;
          }
          if (!receivedAudioLevel) {
            receivedAudioLevel = true;
            _log.info(
              'first microphone level elapsedMs=${elapsed.elapsedMilliseconds}',
              tag: _tag,
            );
          }
          final now = DateTime.now();
          if (_lastInputLevelLog == null ||
              now.difference(_lastInputLevelLog!) >=
                  const Duration(seconds: 1)) {
            _lastInputLevelLog = now;
            _log.debug(
              'input sound level=${level.toStringAsFixed(1)} dB',
              tag: _tag,
            );
          }
          _soundLevel.add(level);
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          onDevice: _useOfflineRecognition,
          listenMode: ListenMode.dictation,
          autoPunctuation: true,
          // Give the user time to begin speaking after activating the mic.
          pauseFor: _isAndroid ? null : const Duration(seconds: 5),
          listenFor: const Duration(seconds: 55),
          localeId: _localeId,
        ),
      );
      _log.info(
        'listen returned listening=${_speech.isListening} '
        'elapsedMs=${elapsed.elapsedMilliseconds}',
        tag: _tag,
      );
      if (!_enabled || _paused) {
        if (_speech.isListening) {
          await _speech.cancel();
        }
      }
    } catch (error, stackTrace) {
      _log.error(
        'listen failed',
        tag: _tag,
        error: error,
        stackTrace: stackTrace,
      );
      _scheduleRestart(_restartDelay);
    }
  }

  void _onStatus(String status) {
    if (!_enabled || _paused) {
      return;
    }
    _log.debug('status: $status', tag: _tag);
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      _scheduleRestart(_restartDelay);
    }
  }

  void _onError(SpeechRecognitionError error) {
    if (!_enabled || _paused) {
      return;
    }

    _log.warn(
      'error: ${error.errorMsg} permanent=${error.permanent}',
      tag: _tag,
    );
    if (_isAndroid &&
        !_triedOfflineRecognition &&
        (error.errorMsg == 'error_network' ||
            error.errorMsg == 'error_network_timeout' ||
            error.errorMsg == 'error_server' ||
            error.errorMsg == 'error_server_disconnected' ||
            error.errorMsg == 'error_no_match')) {
      _triedOfflineRecognition = true;
      _useOfflineRecognition = true;
      _log.info('retrying with on-device speech recognition', tag: _tag);
    } else if (_useOfflineRecognition &&
        (error.errorMsg.contains('language') ||
            error.errorMsg.contains('disabled') ||
            error.errorMsg == 'error_client')) {
      _useOfflineRecognition = false;
      _log.info(
        'on-device recognition unavailable; using system recognizer',
        tag: _tag,
      );
    } else {
      _handleRecognitionError(error);
      return;
    }
    _restartTimer?.cancel();
    _restartScheduled = false;
    _scheduleRestart(_restartDelay);
  }

  void _handleRecognitionError(SpeechRecognitionError error) {
    final permanent =
        error.permanent &&
        (error.errorMsg.contains('permission') ||
            error.errorMsg.contains('disabled') ||
            error.errorMsg.contains('language'));
    if (permanent) {
      _enabled = false;
      _restartTimer?.cancel();
      _restartScheduled = false;
      return;
    }

    // Android reports these as permanent even though they are expected when
    // the user pauses or the recognizer hears no speech. Reopen promptly so
    // the next utterance is still captured.
    if (error.errorMsg == 'error_no_match' ||
        error.errorMsg == 'error_speech_timeout') {
      _scheduleRestart(_restartDelay, silence: true);
      return;
    }

    final busy = error.errorMsg.contains('busy');
    _scheduleRestart(busy ? _busyDelay : _restartDelay);
  }

  void _scheduleRestart(
    Duration delay, {
    bool silence = false,
  }) {
    if (!_enabled || _paused) {
      return;
    }
    if (_restartScheduled && !silence) {
      return;
    }
    if (_restartScheduled) {
      _restartTimer?.cancel();
    }
    // Native recognition may finish on silence or fail repeatedly on devices
    // without a working speech service. Back off instead of reopening the mic
    // in a tight loop and starving the UI.
    var scheduledDelay = delay;
    if (silence) {
      final retryDelay = Duration(
        milliseconds: 900 * (1 << _silenceRestartAttempts.clamp(0, 3).toInt()),
      );
      _silenceRestartAttempts = (_silenceRestartAttempts + 1)
          .clamp(0, 4)
          .toInt();
      if (retryDelay > scheduledDelay) {
        scheduledDelay = retryDelay;
      }
    } else {
      final retryDelay = Duration(
        milliseconds: 1000 * (1 << _restartAttempts.clamp(0, 3).toInt()),
      );
      _restartAttempts = (_restartAttempts + 1).clamp(0, 4).toInt();
      if (retryDelay > scheduledDelay) {
        scheduledDelay = retryDelay;
      }
    }
    _restartScheduled = true;
    _log.debug(
      'recognition retry delayMs=${scheduledDelay.inMilliseconds} '
      'afterSilence=$silence onDevice=$_useOfflineRecognition',
      tag: _tag,
    );
    _restartTimer = Timer(scheduledDelay, () async {
      _restartScheduled = false;
      if (_enabled && !_paused && !_speech.isListening) {
        await _listen();
      }
    });
  }
}
