import 'dart:math';

import 'package:domain_extention/features/character_stage/domain/entity/character_stage_profile.dart';
import 'package:domain_extention/features/character_stage/presentation/widget/character_model_slot.dart';
import 'package:domain_extention/features/character_stage/presentation/widget/character_stage_scrim.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Сцена персонажа: пока только статичное изображение (без оверлеев анимации).
class CharacterStage extends StatefulWidget {
  const CharacterStage({super.key, required this.profile});

  final CharacterStageProfile profile;

  @override
  State<CharacterStage> createState() => _CharacterStageState();
}

class _CharacterStageState extends State<CharacterStage> {
  String? _selectedFigure;
  int _selectionGeneration = 0;

  @override
  void initState() {
    super.initState();
    _selectRandomFigure();
  }

  @override
  void didUpdateWidget(covariant CharacterStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.id != widget.profile.id) {
      _selectedFigure = null;
      _selectRandomFigure();
    }
  }

  Future<void> _selectRandomFigure() async {
    final generation = ++_selectionGeneration;
    final characterId = widget.profile.id;
    final directory = 'assets/characters/$characterId/stage/variants/';
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final candidates = manifest
          .listAssets()
          .where((asset) => asset.startsWith(directory))
          .where((asset) {
            final extension = asset.toLowerCase();
            return extension.endsWith('.png') ||
                extension.endsWith('.jpg') ||
                extension.endsWith('.jpeg') ||
                extension.endsWith('.webp');
          })
          .toList()
        ..sort();
      if (!mounted ||
          generation != _selectionGeneration ||
          candidates.isEmpty) {
        return;
      }
      setState(() {
        _selectedFigure = candidates[Random().nextInt(candidates.length)];
      });
    } catch (_) {
      // Keep the profile's default image if the asset manifest is unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final figure = _selectedFigure ?? widget.profile.figureAsset;

    return Stack(
      fit: StackFit.expand,
      children: [
        CharacterModelSlot(
          child: figure == null
              ? null
              : Align(
                  alignment: const Alignment(0, .6),
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    heightFactor: 0.75,
                    child: Image.asset(
                      figure,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
        ),
        const CharacterStageScrim(),
      ],
    );
  }
}
