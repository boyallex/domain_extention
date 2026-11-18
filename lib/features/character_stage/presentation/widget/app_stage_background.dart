import 'package:flutter/material.dart';

/// Общий фон сцены персонажа на всё приложение.
class AppStageBackground extends StatelessWidget {
  const AppStageBackground({super.key, this.child});

  static const assetPath =
      'assets/characters/sukuna/stage/background.png';

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF0A0608)),
        Image.asset(
          assetPath,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
        ),
        ?child,
      ],
    );
  }
}
