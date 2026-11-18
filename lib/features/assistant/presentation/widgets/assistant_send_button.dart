import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AssistantSendButton extends StatelessWidget {
  const AssistantSendButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    return GlassIconButton(
      onPressed: loading ? null : onPressed,
      size: theme.iconButtonSize,
      iconSize: theme.iconGlyphSize,
      useOwnLayer: true,
      quality: GlassQuality.standard,
      settings: theme.controlSettings,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.arrow_upward_rounded, color: SukunaTheme.bone),
    );
  }
}
