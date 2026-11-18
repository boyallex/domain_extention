import 'package:domain_extention/app/theme/i_character_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract interface class IAppTheme implements Listenable {
  ThemeData get light;

  ThemeData get dark;

  void apply(ICharacterTheme character);
}
