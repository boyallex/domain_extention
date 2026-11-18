import 'package:domain_extention/features/listening/domain/entity/speech_chunk.dart';
import 'package:domain_extention/features/listening/domain/entity/speech_permission.dart';

abstract interface class ISpeechToTextDatasource {
  Stream<SpeechChunk> get transcripts;

  Stream<double> get soundLevel;

  bool get isListening;

  Future<SpeechPermission> permissionStatus();

  Future<bool> hasPermission();

  Future<bool> requestPermission();

  Future<bool> openPermissionSettings({String target = 'auto'});

  Future<bool> start({String? localeId});

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();
}
