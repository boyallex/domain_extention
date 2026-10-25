import 'package:domain_extention/app/profile/i_character_profile.dart';
import 'package:flutter/services.dart';

class SukunaProfile implements ICharacterProfile {
  const SukunaProfile({required this.prompt});

  @override
  String get id => 'sukuna';

  @override
  String get name => 'Рёмен Сукуна';

  @override
  final String prompt;

  static Future<SukunaProfile> load() async {
    final system = await rootBundle.loadString(
      'assets/characters/sukuna/prompts/system.md',
    );
    final examples = await rootBundle.loadString(
      'assets/characters/sukuna/prompts/examples.md',
    );
    final tools = await rootBundle.loadString(
      'assets/characters/sukuna/prompts/tools.md',
    );
    final postHistory = await rootBundle.loadString(
      'assets/characters/sukuna/prompts/post_history.md',
    );

    return SukunaProfile(
      prompt: '$system\n\n$examples\n\n$tools\n\n$postHistory',
    );
  }
}
