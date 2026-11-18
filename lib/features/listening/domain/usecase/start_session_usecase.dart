import 'package:domain_extention/features/listening/domain/repository/i_speech_repository.dart';
import 'package:domain_extention/features/listening/domain/usecase/i_start_session_usecase.dart';

class StartSessionUsecase implements IStartSessionUsecase {
  StartSessionUsecase(this._speechRepository);

  final ISpeechRepository _speechRepository;

  @override
  Future<bool> call({String? localeId}) {
    return _speechRepository.start(localeId: localeId);
  }
}
