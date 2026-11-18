import 'package:domain_extention/features/assistant/domain/parser/assistant_reply_parser.dart';
import 'package:domain_extention/features/character_stage/domain/entity/character_emotion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = AssistantReplyParser();

  test('парсит JSON эмоции и отделяет текст', () {
    final payload = parser.parse(
      '{"emotion":"amused","delay_ms":400}\nНу? Не тяни.',
    );

    expect(payload.emotionResolved, isTrue);
    expect(payload.cue?.emotion, CharacterEmotion.amused);
    expect(payload.cue?.delay, const Duration(milliseconds: 400));
    expect(payload.text, 'Ну? Не тяни.');
  });

  test('без JSON возвращает весь текст', () {
    final payload = parser.parse('Просто фраза.');

    expect(payload.cue, isNull);
    expect(payload.text, 'Просто фраза.');
  });

  test('неполный JSON в стриме не отдаёт текст', () {
    final payload = parser.parse('{"emotion":"idle","delay_ms":');

    expect(payload.emotionResolved, isFalse);
    expect(payload.text, isEmpty);
    expect(payload.cue, isNull);
  });

  test('неизвестный emotion игнорирует блок', () {
    final payload = parser.parse(
      '{"emotion":"rage","delay_ms":10}\nТекст',
    );

    expect(payload.cue, isNull);
    expect(payload.text, 'Текст');
  });

  test('пустой JSON-объект не попадает в текст чата', () {
    final payload = parser.parse('{}\nОк');

    expect(payload.cue, isNull);
    expect(payload.text, 'Ок');
  });
}
