part of 'character_stage_cubit.dart';

class CharacterStageState {
  const CharacterStageState({
    required this.selected,
    required this.catalog,
  });

  final CharacterStageProfile selected;
  final List<CharacterStageProfile> catalog;
}
