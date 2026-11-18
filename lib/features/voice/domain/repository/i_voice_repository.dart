import 'dart:typed_data';

abstract interface class IVoiceRepository {
  Future<Uint8List> speak(String text);
}
