import 'dart:typed_data';

import 'package:domain_extention/features/voice/domain/entity/cloned_voice.dart';
import 'package:domain_extention/features/voice/domain/repository/i_cloned_voice_repository.dart';
import 'package:domain_extention/features/voice/domain/usecase/i_synthesize_speech.dart';

class SynthesizeSpeech implements ISynthesizeSpeech {
  const SynthesizeSpeech({required IClonedVoiceRepository this._repository});

  final IClonedVoiceRepository _repository;

  @override
  Future<Uint8List> call({
    required String text,
    required ClonedVoice voice,
  }) {
    return _repository.speak(text: text, voice: voice);
  }
}
