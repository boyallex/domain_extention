import 'dart:math' as math;

import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';

/// Слот waveform: простая визуализация уровня голоса.
/// Другой агент может заменить на полноценный spectrum.
class AssistantWaveformSlot extends StatelessWidget {
  const AssistantWaveformSlot({
    super.key,
    required this.level,
    required this.active,
    this.height = 36,
    this.width = 160,
  });

  final double level;
  final bool active;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    final driven = active ? level.clamp(0.08, 1.0) : 0.12;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _WaveformPainter(
          level: driven,
          inbound: theme.voiceInboundColor,
          outbound: theme.voiceOutboundColor,
          active: active,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.level,
    required this.inbound,
    required this.outbound,
    required this.active,
  });

  final double level;
  final Color inbound;
  final Color outbound;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    const bars = 28;
    final gap = size.width / bars;
    final midY = size.height / 2;
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var i = 0; i < bars; i++) {
      final t = i / (bars - 1);
      final wave = math.sin(t * math.pi * 3 + level * 6) * 0.5 + 0.5;
      final envelope = math.sin(t * math.pi);
      final barH =
          size.height * (0.12 + 0.88 * wave * envelope * level) * 0.5;
      paint.color = Color.lerp(inbound, outbound, t)!
          .withValues(alpha: active ? 0.85 : 0.28);
      paint.strokeWidth = math.max(2, gap * 0.45);
      final x = gap * i + gap / 2;
      canvas.drawLine(
        Offset(x, midY - barH),
        Offset(x, midY + barH),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.active != active ||
        oldDelegate.inbound != inbound ||
        oldDelegate.outbound != outbound;
  }
}
