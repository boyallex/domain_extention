import 'package:flutter/material.dart';

abstract interface class ICharacterTheme {
  String get id;

  ThemeData get light;

  ThemeData get dark;
}
