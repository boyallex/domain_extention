import 'package:flutter/material.dart';

/// Центральная 2D-фигура персонажа с лёгким покачиванием.
class CharacterFigure extends StatefulWidget {
  const CharacterFigure({super.key, required this.asset});

  final String asset;

  @override
  State<CharacterFigure> createState() => _CharacterFigureState();
}

class _CharacterFigureState extends State<CharacterFigure>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sway = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 7500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sway,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_sway.value);
        return Transform.translate(
          offset: Offset(0, -10 * t),
          child: Transform.rotate(
            angle: -0.01 + 0.02 * t,
            alignment: const Alignment(0, 0.7),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: const Alignment(0, 0.35),
        child: FractionallySizedBox(
          heightFactor: 0.78,
          child: Image.asset(
            widget.asset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
