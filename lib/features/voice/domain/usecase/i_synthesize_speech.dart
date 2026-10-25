import 'dart:typed_data';

import 'package:domain_extention/features/voice/domain/entity/cloned_voice.dart';

abstract interface class ISynthesizeSpeech {
  Future<Uint8List> call({
    required String text,
    required ClonedVoice voice,
  });
}
