/// Три базовые эмоции модели персонажа (заглушки анимаций, без ассетов).
///
/// - [idle] — нейтральное ожидание / спокойная поза по умолчанию.
/// - [amused] — самодовольная ухмылка, лёгкая насмешка (аналог «happy» для
///   высокомерного аниме-ассистента вроде Сукуны).
/// - [scornful] — презрение / вспышка раздражения (аналог «sad/angry» в
///   характере короля проклятий: не «грусть», а холодный отказ).
enum CharacterEmotion {
  idle,
  amused,
  scornful;

  /// Значения, которые нейросеть должна писать в JSON-поле `emotion`.
  String get wireName => name;

  static CharacterEmotion? tryParse(String? raw) {
    if (raw == null) {
      return null;
    }
    final key = raw.trim().toLowerCase();
    for (final value in CharacterEmotion.values) {
      if (value.name == key) {
        return value;
      }
    }
    return null;
  }
}
