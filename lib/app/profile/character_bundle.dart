import 'package:domain_extention/app/profile/i_character_bundle.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class CharacterBundle implements ICharacterBundle {
  const CharacterBundle({
    required this.id,
    required this.name,
    required this.locale,
    required this.themeId,
    required this.profileId,
    required this.voiceRemoteId,
    required this.voiceApiBaseUrl,
    required this.voiceApiPath,
    required this.voiceModel,
    required this.promptPath,
    required this.voiceManifestPath,
  });

  @override
  final String id;

  final String name;
  final String locale;
  final String themeId;
  final String profileId;
  final String voiceRemoteId;
  final String voiceApiBaseUrl;
  final String voiceApiPath;
  final String voiceModel;

  @override
  final String promptPath;

  @override
  final String voiceManifestPath;

  static const sukunaAsset = 'assets/characters/sukuna/character.yaml';

  static Future<CharacterBundle> loadSukuna() async {
    final raw = await rootBundle.loadString(sukunaAsset);
    final yaml = loadYaml(raw) as YamlMap;

    return CharacterBundle(
      id: yaml['id'] as String,
      name: yaml['name'] as String,
      locale: yaml['locale'] as String,
      themeId: yaml['theme_id'] as String,
      profileId: yaml['profile_id'] as String,
      voiceRemoteId: yaml['voice_remote_id'] as String,
      voiceApiBaseUrl: yaml['voice_api_base_url'] as String,
      voiceApiPath: yaml['voice_api_path'] as String,
      voiceModel: yaml['voice_model'] as String,
      promptPath: 'assets/characters/sukuna/prompts/',
      voiceManifestPath: 'assets/characters/sukuna/voice/manifest.yaml',
    );
  }
}
