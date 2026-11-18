import 'dart:typed_data';

import 'package:domain_extention/features/voice/domain/entity/playback_end.dart';
import 'package:domain_extention/features/voice/domain/entity/voice_playback_status.dart';

abstract interface class IVoicePlayback {
  Stream<VoicePlaybackStatus> get status;

  bool get isPlaying;

  Future<PlaybackEnd> play(Uint8List bytes);

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();
}
