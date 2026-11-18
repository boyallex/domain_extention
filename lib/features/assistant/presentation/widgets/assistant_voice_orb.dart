import 'dart:math' as math;

import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Круг голосового режима: цвет входящего/исходящего, пульс от уровня.
class AssistantVoiceOrb extends StatefulWidget {
  const AssistantVoiceOrb({
    super.key,
    required this.listening,
    required this.speaking,
    required this.level,
    required this.onPressed,
  });

  final bool listening;
  final bool speaking;
  final double level;
  final VoidCallback onPressed;

  @override
  State<AssistantVoiceOrb> createState() => _AssistantVoiceOrbState();
}

class _AssistantVoiceOrbState extends State<AssistantVoiceOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    final color = widget.speaking
        ? theme.voiceOutboundColor
        : theme.voiceInboundColor;
    final caption = widget.speaking
        ? 'говорит'
        : widget.listening
        ? 'слушает'
        : 'голос';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final driven = widget.speaking
                ? 0.35 + 0.65 * _pulse.value
                : widget.level.clamp(0.0, 1.0);
            final scale = 1 + 0.04 * _pulse.value + 0.18 * driven;
            return Transform.scale(
              scale: scale,
              child: CustomPaint(
                painter: _OrbPainter(color: color, level: driven),
                child: child,
              ),
            );
          },
          child: SizedBox(
            width: 132,
            height: 132,
            child: Center(
              child: GlassButton.custom(
                onTap: widget.onPressed,
                enabled: true,
                useOwnLayer: true,
                quality: GlassQuality.standard,
                settings: theme.controlSettings,
                shape: const LiquidOval(),
                child: SizedBox(
                  width: 118,
                  height: 118,
                  child: Center(
                    child: _Bars(
                      color: color,
                      level: widget.level,
                      active: widget.listening || widget.speaking,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption.toUpperCase(),
          style: TextStyle(
            color: theme.stageBone.withValues(alpha: 0.55),
            fontSize: 11,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({
    required this.color,
    required this.level,
    required this.active,
  });

  final Color color;
  final double level;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final heights = [0.35, 0.7, 1.0, 0.65, 0.4];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < heights.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Container(
              width: 3,
              height: 10 +
                  22 *
                      heights[i] *
                      (active ? (0.35 + 0.65 * level) : 0.25),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
      ],
    );
  }
}

class _OrbPainter extends CustomPainter {
  const _OrbPainter({required this.color, required this.level});

  final Color color;
  final double level;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    canvas.drawCircle(
      center,
      radius - 10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      center,
      radius - 2 + 4 * level,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.28),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.level != level;
  }
}
