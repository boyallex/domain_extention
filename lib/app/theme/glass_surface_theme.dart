import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Общие стеклянные контролы и токены одностраничника.
abstract class GlassSurfaceTheme {
  const GlassSurfaceTheme();

  static final Color _glassColor = GlassThemeSettings.ios27Dark.glassColor!
      .withValues(alpha: GlassThemeSettings.ios27Dark.glassColor!.a / 2);

  static final GlassThemeSettings _settings = GlassThemeSettings.ios27Dark
      .copyWith(
        glassColor: _glassColor,
        frostOpacity: GlassThemeSettings.ios27Dark.frostOpacity! / 2,
      );

  static final GlassThemeData _glassData = GlassThemeData(
    brightness: Brightness.dark,
    light: GlassThemeVariant(settings: _settings),
    dark: GlassThemeVariant(settings: _settings),
  );

  static final LiquidGlassSettings _controlSettings = _settings.applyTo(
    const LiquidGlassSettings(),
  );

  GlassThemeData get glassData => _glassData;

  LiquidGlassSettings get controlSettings => _controlSettings;

  EdgeInsets get controlMargin => const EdgeInsets.fromLTRB(8, 0, 8, 8);

  double get controlGap => 4;

  EdgeInsets get controlPadding =>
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6);

  EdgeInsets get wideControlPadding =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

  double get iconButtonSize => 36;

  double get iconGlyphSize => 22;

  double get fieldRadius => 18;

  /// Высота прозрачного чата над композером: 120–160.
  double get chatOverlayHeight => 148;

  Color get stageInk;

  Color get stageAccent;

  Color get stageBone;

  /// Входящий звук (микрофон).
  Color get voiceInboundColor;

  /// Исходящий звук (ответ персонажа).
  Color get voiceOutboundColor;

  static TextStyle replyText({required Color color, required bool live}) {
    return TextStyle(
      color: color.withValues(alpha: live ? 0.56 : 0.7),
      fontWeight: FontWeight.w600,
      fontStyle: live ? FontStyle.italic : null,
      height: 1.3,
      fontSize: 14.5,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.65),
          blurRadius: 10,
        ),
      ],
    );
  }
}
