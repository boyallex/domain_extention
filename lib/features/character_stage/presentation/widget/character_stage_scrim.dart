import 'package:flutter/material.dart';

/// Затемнение сверху и снизу, чтобы стекло и текст читались поверх сцены.
class CharacterStageScrim extends StatelessWidget {
  const CharacterStageScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x66080404),
              Color(0x00080404),
              Color(0x00080404),
              Color(0x99080404),
            ],
            stops: [0, 0.2, 0.58, 1],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}
