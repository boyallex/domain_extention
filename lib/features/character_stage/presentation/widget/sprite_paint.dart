import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// Рисует Flame [Sprite] в обычном Flutter layout (без GameWidget).
class SpritePaint extends StatelessWidget {
  const SpritePaint({
    super.key,
    required this.sprite,
    this.fit = BoxFit.contain,
  });

  final Sprite sprite;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpritePainter(sprite: sprite, fit: fit),
      child: const SizedBox.expand(),
    );
  }
}

class _SpritePainter extends CustomPainter {
  _SpritePainter({required this.sprite, required this.fit});

  final Sprite sprite;
  final BoxFit fit;

  @override
  void paint(Canvas canvas, Size size) {
    final srcSize = sprite.srcSize;
    final fitted = applyBoxFit(
      fit,
      Size(srcSize.x, srcSize.y),
      size,
    );
    final output = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & size,
    );
    sprite.render(
      canvas,
      position: Vector2(output.left, output.top),
      size: Vector2(output.width, output.height),
    );
  }

  @override
  bool shouldRepaint(covariant _SpritePainter oldDelegate) {
    return oldDelegate.sprite != sprite || oldDelegate.fit != fit;
  }
}
