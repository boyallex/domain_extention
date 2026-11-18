import 'package:domain_extention/features/voice/domain/entity/playback_intent.dart';
import 'package:domain_extention/features/voice/domain/usecase/i_toggle_playback_usecase.dart';

class TogglePlaybackUsecase implements ITogglePlaybackUsecase {
  const TogglePlaybackUsecase();

  @override
  PlaybackIntent? call({
    required bool hasAudio,
    required bool isCurrentClip,
    required bool isPlaying,
    required bool isCompleted,
  }) {
    if (!hasAudio) {
      return null;
    }
    if (isCurrentClip && isPlaying) {
      return PlaybackIntent.pause;
    }
    if (isCurrentClip && !isPlaying && !isCompleted) {
      return PlaybackIntent.resume;
    }
    return PlaybackIntent.play;
  }
}
