import 'dart:typed_data';

abstract interface class IAnswerMessageUsecase {
  Future<Uint8List> call(String message);
}
