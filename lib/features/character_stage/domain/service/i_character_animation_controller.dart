import 'package:domain_extention/features/character_stage/domain/entity/character_emotion.dart';
import 'package:domain_extention/features/character_stage/domain/entity/character_emotion_cue.dart';

/// API запуска анимаций модели. Реализация пока без ассетов — только состояние.
abstract interface class ICharacterAnimationController {
  CharacterEmotion get current;

  /// Запланированная эмоция, если [schedule] ещё не сработал; иначе `null`.
  CharacterEmotionCue? get scheduled;

  /// Немедленный запуск эмоции; отменяет отложенный [schedule].
  void play(CharacterEmotion emotion);

  /// Возврат в [CharacterEmotion.idle] и отмена отложенного запуска.
  void stop();

  /// Запуск эмоции через [delay]. При нулевой/отрицательной задержке = [play].
  void schedule(CharacterEmotion emotion, Duration delay);

  /// Удобный вход для директивы из парсера ответа нейросети.
  void applyCue(CharacterEmotionCue cue);
}
