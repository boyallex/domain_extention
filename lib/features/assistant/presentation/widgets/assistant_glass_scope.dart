import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AssistantGlassScope extends StatelessWidget {
  const AssistantGlassScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassTheme(
      data: const SukunaTheme().glassData,
      child: child,
    );
  }
}
