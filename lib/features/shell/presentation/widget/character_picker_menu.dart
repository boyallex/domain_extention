import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/character_stage/domain/entity/character_stage_profile.dart';
import 'package:domain_extention/features/shell/presentation/widget/character_picker_item.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class CharacterPickerMenu extends StatelessWidget {
  const CharacterPickerMenu({
    super.key,
    required this.currentId,
    required this.catalog,
    required this.onSelect,
    required this.onDismiss,
  });

  final String currentId;
  final List<CharacterStageProfile> catalog;
  final ValueChanged<String> onSelect;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.25),
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 72, left: 24),
            child: GestureDetector(
              onTap: () {},
              child: GlassContainer(
                width: 248,
                useOwnLayer: true,
                quality: GlassQuality.standard,
                settings: theme.controlSettings,
                shape: const LiquidRoundedRectangle(borderRadius: 22),
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final profile in catalog)
                      CharacterPickerItem(
                        title: profile.name,
                        subtitle: profile.enabled
                            ? (profile.id == currentId ? 'сейчас' : 'выбрать')
                            : 'позже',
                        selected: profile.id == currentId,
                        enabled: profile.enabled,
                        onTap: () {
                          onSelect(profile.id);
                          onDismiss();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
