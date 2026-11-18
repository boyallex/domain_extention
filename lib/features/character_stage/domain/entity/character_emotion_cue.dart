import 'package:domain_extention/features/character_stage/domain/entity/character_emotion.dart';

/// Директива эмоции из ответа нейросети: какую анимацию сыграть и через сколько.
class CharacterEmotionCue {
  const CharacterEmotionCue({
    required this.emotion,
    this.delay = Duration.zero,
  });

  final CharacterEmotion emotion;
  final Duration delay;

  bool get isImmediate => delay <= Duration.zero;
}
