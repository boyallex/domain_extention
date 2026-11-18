import 'package:domain_extention/features/listening/data/datasource/i_speech_to_text_datasource.dart';
import 'package:domain_extention/features/listening/domain/entity/speech_chunk.dart';
import 'package:domain_extention/features/listening/domain/entity/speech_permission.dart';
import 'package:domain_extention/features/listening/domain/repository/i_speech_repository.dart';

class SpeechRepository implements ISpeechRepository {
  SpeechRepository({required this._datasource});

  final ISpeechToTextDatasource _datasource;

  @override
  Stream<SpeechChunk> get transcripts => _datasource.transcripts;

  @override
  Stream<double> get soundLevel => _datasource.soundLevel;

  @override
  bool get isListening => _datasource.isListening;

  @override
  Future<SpeechPermission> permissionStatus() {
    return _datasource.permissionStatus();
  }

  @override
  Future<bool> hasPermission() {
    return _datasource.hasPermission();
  }

  @override
  Future<bool> requestPermission() {
    return _datasource.requestPermission();
  }

  @override
  Future<bool> openPermissionSettings({String target = 'auto'}) {
    return _datasource.openPermissionSettings(target: target);
  }

  @override
  Future<bool> start({String? localeId}) {
    return _datasource.start(localeId: localeId);
  }

  @override
  Future<void> pause() {
    return _datasource.pause();
  }

  @override
  Future<void> resume() {
    return _datasource.resume();
  }

  @override
  Future<void> stop() {
    return _datasource.stop();
  }
}
