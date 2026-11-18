import 'dart:typed_data';

import 'package:domain_extention/features/assistant/domain/usecase/i_answer_message_usecase.dart';
import 'package:domain_extention/features/voice/domain/repository/i_voice_repository.dart';

class AnswerMessageUsecase implements IAnswerMessageUsecase {
  AnswerMessageUsecase(this._voiceRepository);

  final IVoiceRepository _voiceRepository;

  @override
  Future<Uint8List> call(String message) {
    return _voiceRepository.speak(message);
  }
}
