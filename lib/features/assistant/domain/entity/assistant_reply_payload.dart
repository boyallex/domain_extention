import 'package:domain_extention/features/character_stage/domain/entity/character_emotion_cue.dart';

/// Разобранный ответ ассистента: опциональная директива эмоции + чистый текст.
class AssistantReplyPayload {
  const AssistantReplyPayload({
    required this.text,
    this.cue,
    this.emotionResolved = true,
  });

  /// Текст для чата и TTS (без JSON-блока эмоции).
  final String text;

  /// Эмоция + delay из ведущего JSON; `null`, если блока не было.
  final CharacterEmotionCue? cue;

  /// Для стрима: `false`, пока ведущий JSON ещё не закрыт — текст показывать рано.
  final bool emotionResolved;
}
