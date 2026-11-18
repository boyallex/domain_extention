import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AssistantMicButton extends StatelessWidget {
  const AssistantMicButton({
    super.key,
    required this.listening,
    required this.onPressed,
    this.expanded = false,
    this.connecting = false,
  });

  final bool listening;
  final VoidCallback onPressed;
  final bool expanded;
  final bool connecting;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    if (expanded) {
      return GlassButton.custom(
        onTap: onPressed,
        enabled: true,
        useOwnLayer: true,
        quality: GlassQuality.standard,
        settings: theme.controlSettings,
        shape: const LiquidRoundedRectangle(
          borderRadius: GlassDefaults.capsuleRadius,
        ),
        child: Padding(
          padding: theme.wideControlPadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (connecting)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.mic_rounded, color: SukunaTheme.bone),
              const SizedBox(width: 8),
              Text(
                connecting
                    ? 'Подключение…'
                    : listening
                    ? 'Слушает'
                    : 'Начать диалог',
                style: const TextStyle(color: SukunaTheme.bone),
              ),
            ],
          ),
        ),
      );
    }

    return GlassIconButton(
      icon: connecting
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              listening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: SukunaTheme.bone,
            ),
      semanticLabel: connecting
          ? 'Подключение микрофона'
          : listening
          ? 'Слушает'
          : 'Начать диалог',
      onPressed: connecting ? null : onPressed,
      size: theme.iconButtonSize,
      iconSize: theme.iconGlyphSize,
      useOwnLayer: true,
      quality: GlassQuality.standard,
      settings: theme.controlSettings,
    );
  }
}
