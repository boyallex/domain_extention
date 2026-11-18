import 'package:domain_extention/features/character_stage/domain/entity/character_stage_profile.dart';

abstract interface class ICharacterStageCatalog {
  List<CharacterStageProfile> all();

  CharacterStageProfile byId(String id);

  CharacterStageProfile get defaultProfile;
}
