import 'package:domain_extention/app/theme/i_app_theme.dart';
import 'package:domain_extention/app/theme/i_character_theme.dart';
import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier implements IAppTheme {
  AppTheme({this._character});

  static final ThemeData _fallback = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
  );

  ICharacterTheme? _character;

  @override
  void apply(ICharacterTheme character) {
    _character = character;
    notifyListeners();
  }

  @override
  ThemeData get light => _character?.light ?? _fallback;

  @override
  ThemeData get dark => _character?.dark ?? _fallback;
}
