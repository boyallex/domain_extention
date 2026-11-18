import 'package:domain_extention/features/voice/domain/entity/playback_intent.dart';

abstract interface class ITogglePlaybackUsecase {
  PlaybackIntent? call({
    required bool hasAudio,
    required bool isCurrentClip,
    required bool isPlaying,
    required bool isCompleted,
  });
}
