import 'package:flutter/material.dart';

/// Фон сцены текущего персонажа.
class CharacterBackdrop extends StatelessWidget {
  const CharacterBackdrop({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }
}
