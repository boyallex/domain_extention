import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AssistantGlassField extends StatelessWidget {
  const AssistantGlassField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    return GlassTextField(
      controller: controller,
      placeholder: hintText,
      textStyle: const TextStyle(color: SukunaTheme.bone),
      placeholderStyle: TextStyle(
        color: SukunaTheme.bone.withValues(alpha: 0.4),
      ),
      padding: theme.controlPadding,
      shape: LiquidRoundedRectangle(borderRadius: theme.fieldRadius),
      useOwnLayer: true,
      quality: GlassQuality.standard,
      settings: theme.controlSettings,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => onSubmitted(),
    );
  }
}
