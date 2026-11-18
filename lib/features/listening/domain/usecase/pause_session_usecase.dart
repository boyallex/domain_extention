import 'package:domain_extention/features/listening/domain/repository/i_speech_repository.dart';
import 'package:domain_extention/features/listening/domain/usecase/i_pause_session_usecase.dart';

class PauseSessionUsecase implements IPauseSessionUsecase {
  PauseSessionUsecase(this._speechRepository);

  final ISpeechRepository _speechRepository;

  @override
  Future<void> call() {
    return _speechRepository.pause();
  }
}
