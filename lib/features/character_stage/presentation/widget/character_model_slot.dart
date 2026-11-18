import 'package:flutter/material.dart';

/// Слот под анимацию модели персонажа (2D Flame / будущий Rive / 3D).
class CharacterModelSlot extends StatelessWidget {
  const CharacterModelSlot({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.expand();
  }
}
