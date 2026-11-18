import 'package:domain_extention/features/home_widget/i_character_home_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class CharacterHomeWidget implements ICharacterHomeWidget {
  const CharacterHomeWidget();

  static const _channel = MethodChannel('domain_extention/native_widget');
  static const _iconLimit = 512 * 1024;

  @override
  Future<void> setCharacter(String characterId) async {
    Uint8List? icon;
    try {
      if (characterId == 'sukuna' || characterId == 'gojo') {
        final asset = await rootBundle.load(
          'assets/widget_icons/$characterId.png',
        );
        icon = asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes);
      } else {
        icon = await FirebaseStorage.instance
            .ref('widget_icons/$characterId.png')
            .getData(_iconLimit);
      }
    } on FirebaseException {
      // Native fallback artwork keeps the widget usable while Storage is empty
      // or unreachable. Upload the documented PNG to enable remote artwork.
    }

    try {
      await _channel.invokeMethod<void>('setCharacter', {
        'characterId': characterId,
        'imageBytes': icon,
      });
    } on MissingPluginException {
      // Desktop builds and iOS before its WidgetKit target is configured.
    }
  }
}
