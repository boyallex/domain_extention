part of 'character_animation_cubit.dart';

class CharacterAnimationState {
  const CharacterAnimationState({
    this.current = CharacterEmotion.idle,
    this.scheduled,
  });

  final CharacterEmotion current;
  final CharacterEmotionCue? scheduled;

  CharacterAnimationState copyWith({
    CharacterEmotion? current,
    CharacterEmotionCue? scheduled,
    bool clearScheduled = false,
  }) {
    return CharacterAnimationState(
      current: current ?? this.current,
      scheduled: clearScheduled ? null : (scheduled ?? this.scheduled),
    );
  }
}
