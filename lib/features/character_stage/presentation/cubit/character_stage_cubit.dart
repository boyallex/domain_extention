import 'dart:async';

import 'package:domain_extention/features/character_stage/domain/entity/character_stage_profile.dart';
import 'package:domain_extention/features/character_stage/domain/repository/i_character_stage_catalog.dart';
import 'package:domain_extention/features/home_widget/character_home_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'character_stage_state.dart';

class CharacterStageCubit extends Cubit<CharacterStageState> {
  CharacterStageCubit({required ICharacterStageCatalog catalog})
    : _catalog = catalog,
      super(
        CharacterStageState(
          selected: catalog.defaultProfile,
          catalog: catalog.all(),
        ),
      ) {
    unawaited(CharacterHomeWidget().setCharacter(state.selected.id));
  }

  final ICharacterStageCatalog _catalog;

  void select(String id) {
    final profile = _catalog.byId(id);
    if (!profile.enabled || profile.id == state.selected.id) {
      return;
    }
    emit(
      CharacterStageState(
        selected: profile,
        catalog: state.catalog,
      ),
    );
    unawaited(CharacterHomeWidget().setCharacter(profile.id));
  }
}
