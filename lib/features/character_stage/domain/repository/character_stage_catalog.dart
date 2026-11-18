import 'package:domain_extention/features/character_stage/domain/entity/character_stage_profile.dart';
import 'package:domain_extention/features/character_stage/domain/repository/i_character_stage_catalog.dart';

class CharacterStageCatalog implements ICharacterStageCatalog {
  const CharacterStageCatalog();

  static const _sukuna = CharacterStageProfile(
    id: 'sukuna',
    name: 'Рёмен Сукуна',
    enabled: true,
    figureAsset: 'assets/characters/sukuna/stage/figure.png',
    backdropAsset: 'assets/characters/sukuna/stage/background.png',
  );

  static const _gojo = CharacterStageProfile(
    id: 'gojo',
    name: 'Сатору Годжо',
    enabled: false,
  );

  static const _jarvis = CharacterStageProfile(
    id: 'jarvis',
    name: 'Джарвис',
    enabled: false,
  );

  static const _all = [_sukuna, _gojo, _jarvis];

  @override
  List<CharacterStageProfile> all() => _all;

  @override
  CharacterStageProfile get defaultProfile => _sukuna;

  @override
  CharacterStageProfile byId(String id) {
    for (final profile in _all) {
      if (profile.id == id) {
        return profile;
      }
    }
    return defaultProfile;
  }
}
