import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Заготовка жеста/кнопки на другие страницы.
class FuturePagesEdge extends StatelessWidget {
  const FuturePagesEdge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    return Align(
      alignment: Alignment.centerRight,
      child: GlassContainer(
        width: 16,
        height: 74,
        useOwnLayer: true,
        quality: GlassQuality.standard,
        settings: theme.controlSettings,
        shape: const LiquidRoundedRectangle(borderRadius: 12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: theme.stageBone,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
