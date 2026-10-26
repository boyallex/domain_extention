import 'package:domain_extention/app/theme/i_character_theme.dart';
import 'package:flutter/material.dart';

class SukunaTheme implements ICharacterTheme {
  const SukunaTheme();

  @override
  String get id => 'sukuna';

  static const ink = Color(0xFF0C0909);
  static const blood = Color(0xFFB42318);
  static const bone = Color(0xFFF3E6D4);
  static const ash = Color(0xFF2A1C1C);

  ThemeData get _base {
    final scheme = ColorScheme.fromSeed(
      seedColor: blood,
      brightness: Brightness.dark,
      primary: blood,
      surface: ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: ink,
      appBarTheme: const AppBarTheme(
        backgroundColor: ink,
        foregroundColor: bone,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: bone, height: 1.35),
        bodyMedium: TextStyle(color: bone, height: 1.35),
      ),
    );
  }

  @override
  ThemeData get light => _base;

  @override
  ThemeData get dark => _base;
}
