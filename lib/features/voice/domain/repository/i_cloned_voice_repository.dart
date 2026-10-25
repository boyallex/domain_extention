import 'dart:typed_data';

import 'package:domain_extention/features/voice/domain/entity/cloned_voice.dart';

abstract interface class IClonedVoiceRepository {
  Future<ClonedVoice> getByCharacterId(String characterId);

  Future<Uint8List> speak({
    required String text,
    required ClonedVoice voice,
  });
}
