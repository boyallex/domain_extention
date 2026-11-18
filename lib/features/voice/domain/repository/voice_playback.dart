import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:domain_extention/features/voice/domain/entity/playback_end.dart';
import 'package:domain_extention/features/voice/domain/entity/voice_playback_status.dart';
import 'package:domain_extention/features/voice/domain/repository/i_voice_playback.dart';
import 'package:just_audio/just_audio.dart';

class VoicePlayback implements IVoicePlayback {
  VoicePlayback({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _player.playerStateStream.listen((_) => _push());
    _player.positionStream.listen((position) {
      _position = position;
      _push();
    });
    _player.durationStream.listen((duration) {
      if (duration != null && duration > Duration.zero) {
        _duration = duration;
      }
      _push();
    });
    _player.errorStream.listen((_) {
      _sawError = true;
      _push();
    });
  }

  final AudioPlayer _player;
  final _status = StreamController<VoicePlaybackStatus>.broadcast();
  final _generationEvents = StreamController<int>.broadcast();
  Uint8List? _currentBytes;
  File? _clipFile;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int _generation = 0;
  bool _continued = false;
  bool _sawError = false;
  Future<void>? _audioSessionConfiguration;

  static const _precise = ProgressiveAudioSourceOptions(
    darwinAssetOptions: DarwinAssetOptions(
      preferPreciseDurationAndTiming: true,
    ),
  );

  @override
  Stream<VoicePlaybackStatus> get status => _status.stream;

  @override
  bool get isPlaying => _player.playing;

  @override
  Future<PlaybackEnd> play(Uint8List bytes) async {
    final generation = ++_generation;
    _continued = false;
    _sawError = false;
    _generationEvents.add(generation);
    try {
      await _activateAudioSession();
      await _halt();
      if (generation != _generation) {
        return PlaybackEnd.interrupted;
      }

      final file = await _materialize(bytes, generation);
      if (generation != _generation) {
        return PlaybackEnd.interrupted;
      }

      _currentBytes = Uint8List.fromList(bytes);
      _position = Duration.zero;
      final loaded = await _player.setAudioSource(
        ProgressiveAudioSource(Uri.file(file.path), options: _precise),
      );
      if (generation != _generation) {
        return PlaybackEnd.interrupted;
      }

      _duration = loaded ?? _player.duration ?? Duration.zero;
      await _player.seek(Duration.zero);
      if (generation != _generation) {
        return PlaybackEnd.interrupted;
      }
      _push();
      return await _runUntilEnd(generation);
    } catch (error, stackTrace) {
      if (generation != _generation) {
        return PlaybackEnd.interrupted;
      }
      developer.log(
        'playback failed',
        name: 'voice',
        error: error,
        stackTrace: stackTrace,
      );
      _push();
      return PlaybackEnd.failed;
    }
  }

  @override
  Future<void> pause() {
    return _player.pause();
  }

  @override
  Future<void> resume() {
    return _player.play();
  }

  @override
  Future<void> stop() async {
    _generation++;
    _currentBytes = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    _generationEvents.add(_generation);
    await _halt();
    _push();
  }

  Future<PlaybackEnd> _runUntilEnd(int generation) async {
    if (!_player.playing && !_isTerminal) {
      await _player.play();
    }
    while (generation == _generation) {
      final end = _endIfTerminal(generation);
      if (end == PlaybackEnd.interrupted || end == PlaybackEnd.failed) {
        return end!;
      }
      if (end == PlaybackEnd.completed) {
        if (!_continued && _stoppedEarly()) {
          _continued = true;
          await _player.seek(_position);
          if (generation != _generation) {
            return PlaybackEnd.interrupted;
          }
          await _player.play();
          continue;
        }
        return PlaybackEnd.completed;
      }

      await _waitUntilEndOrCancelled(generation);
    }
    return PlaybackEnd.interrupted;
  }

  Future<void> _waitUntilEndOrCancelled(int generation) async {
    final done = Completer<void>();
    final subscriptions = <StreamSubscription<dynamic>>[
      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed && !done.isCompleted) {
          done.complete();
        }
      }),
      _player.errorStream.listen((_) {
        _sawError = true;
        if (!done.isCompleted) {
          done.complete();
        }
      }),
      _generationEvents.stream.listen((value) {
        if (value != generation && !done.isCompleted) {
          done.complete();
        }
      }),
    ];
    try {
      await done.future;
    } finally {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    }
  }

  PlaybackEnd? _endIfTerminal(int generation) {
    if (generation != _generation) {
      return PlaybackEnd.interrupted;
    }
    if (_sawError) {
      return PlaybackEnd.failed;
    }
    if (_player.processingState == ProcessingState.completed) {
      return PlaybackEnd.completed;
    }
    return null;
  }

  bool get _isTerminal =>
      _sawError || _player.processingState == ProcessingState.completed;

  bool _stoppedEarly() {
    final duration = _duration > Duration.zero
        ? _duration
        : (_player.duration ?? Duration.zero);
    if (duration < const Duration(milliseconds: 700)) {
      return false;
    }
    _position = _player.position;
    _duration = duration;
    return _position + const Duration(milliseconds: 450) < duration;
  }

  Future<void> _halt() {
    return _player.stop();
  }

  Future<void> _activateAudioSession() async {
    final session = await AudioSession.instance;
    _audioSessionConfiguration ??= session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions(0xC),
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
      ),
    );
    await _audioSessionConfiguration;
    await session.setActive(true);
  }

  Future<File> _materialize(Uint8List bytes, int generation) async {
    final directory = Directory(
      '${Directory.systemTemp.path}/domain_extention_voice',
    );
    await directory.create(recursive: true);
    final file = File('${directory.path}/speech_$generation.mp3');
    await file.writeAsBytes(bytes, flush: true);
    final previous = _clipFile;
    _clipFile = file;
    if (previous != null && previous.path != file.path) {
      unawaited(
        previous.delete().catchError((Object _) => previous),
      );
    }
    return file;
  }

  void _push() {
    if (_status.isClosed) {
      return;
    }
    final failed = _sawError;
    _status.add(
      VoicePlaybackStatus(
        isPlaying: _player.playing && !failed,
        isCompleted:
            _player.processingState == ProcessingState.completed && !failed,
        position: _position,
        duration: _duration,
        currentBytes: _currentBytes,
      ),
    );
  }
}
