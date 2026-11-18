import 'dart:convert';

import 'package:domain_extention/features/assistant/domain/entity/assistant_reply_payload.dart';
import 'package:domain_extention/features/assistant/domain/parser/i_assistant_reply_parser.dart';
import 'package:domain_extention/features/character_stage/domain/entity/character_emotion.dart';
import 'package:domain_extention/features/character_stage/domain/entity/character_emotion_cue.dart';

/// Формат ответа нейросети:
/// ```
/// {"emotion":"amused","delay_ms":400}
/// Текст реплики для пользователя.
/// ```
/// Первая строка — JSON с `emotion` (`idle` | `amused` | `scornful`) и
/// `delay_ms` (миллисекунды до старта анимации). Далее — обычный текст.
class AssistantReplyParser implements IAssistantReplyParser {
  const AssistantReplyParser();

  @override
  AssistantReplyPayload parse(String raw) {
    final trimmed = raw.trimLeft();
    if (trimmed.isEmpty) {
      return const AssistantReplyPayload(text: '');
    }
    if (!trimmed.startsWith('{')) {
      return AssistantReplyPayload(text: raw.trim());
    }

    final end = _jsonObjectEnd(trimmed);
    if (end == null) {
      // Ведущий JSON ещё не дописан (стрим) — не светим сырой фрагмент в чат.
      return const AssistantReplyPayload(
        text: '',
        emotionResolved: false,
      );
    }

    final jsonChunk = trimmed.substring(0, end + 1);
    final rest = trimmed.substring(end + 1).trim();
    try {
      final decoded = jsonDecode(jsonChunk);
      if (decoded is! Map) {
        // Не объект эмоции — не тащим сырой JSON в чат/TTS.
        return AssistantReplyPayload(text: rest.isNotEmpty ? rest : raw.trim());
      }
      final map = Map<String, dynamic>.from(decoded);
      final emotion = CharacterEmotion.tryParse(map['emotion']?.toString());
      if (emotion == null) {
        // Блок распознан, но emotion неизвестен: текст без JSON, без cue.
        return AssistantReplyPayload(text: rest);
      }
      final delayMs = _readDelayMs(map);
      return AssistantReplyPayload(
        text: rest,
        cue: CharacterEmotionCue(
          emotion: emotion,
          delay: Duration(milliseconds: delayMs),
        ),
      );
    } on FormatException {
      return AssistantReplyPayload(text: raw.trim());
    }
  }

  static int _readDelayMs(Map<String, dynamic> map) {
    final raw = map['delay_ms'] ?? map['delayMs'] ?? map['delay'];
    if (raw is num) {
      return raw.round().clamp(0, 60000);
    }
    if (raw is String) {
      final parsed = num.tryParse(raw.trim());
      if (parsed != null) {
        return parsed.round().clamp(0, 60000);
      }
    }
    return 0;
  }

  /// Индекс закрывающей `}` верхнего уровня или `null`, если объект неполный.
  static int? _jsonObjectEnd(String source) {
    var depth = 0;
    var inString = false;
    var escape = false;
    for (var i = 0; i < source.length; i++) {
      final char = source[i];
      if (inString) {
        if (escape) {
          escape = false;
          continue;
        }
        if (char == '\\') {
          escape = true;
          continue;
        }
        if (char == '"') {
          inString = false;
        }
        continue;
      }
      if (char == '"') {
        inString = true;
        continue;
      }
      if (char == '{') {
        depth++;
        continue;
      }
      if (char == '}') {
        depth--;
        if (depth == 0) {
          return i;
        }
      }
    }
    return null;
  }
}
