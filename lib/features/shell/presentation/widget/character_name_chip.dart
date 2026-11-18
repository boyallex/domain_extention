import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Селектор персонажа: avatar + имя + chevron.
class CharacterNameChip extends StatelessWidget {
  const CharacterNameChip({
    super.key,
    required this.name,
    required this.onTap,
    this.avatarAsset,
  });

  final String name;
  final VoidCallback onTap;
  final String? avatarAsset;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    final initial = name.isNotEmpty ? name.substring(0, 1) : '?';

    return GlassButton.custom(
      onTap: onTap,
      enabled: true,
      useOwnLayer: true,
      quality: GlassQuality.standard,
      settings: theme.controlSettings,
      shape: const LiquidRoundedRectangle(
        borderRadius: GlassDefaults.capsuleRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SizedBox(
                width: 28,
                height: 28,
                child: avatarAsset != null && avatarAsset!.isNotEmpty
                    ? Image.asset(avatarAsset!, fit: BoxFit.cover)
                    : ColoredBox(
                        color: theme.stageAccent.withValues(alpha: 0.55),
                        child: Center(
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: theme.stageBone,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: TextStyle(
                color: theme.stageBone,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.02,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: theme.stageBone.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
