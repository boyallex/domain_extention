import 'package:domain_extention/features/listening/domain/repository/i_speech_repository.dart';
import 'package:domain_extention/features/listening/domain/usecase/i_resume_session_usecase.dart';

class ResumeSessionUsecase implements IResumeSessionUsecase {
  ResumeSessionUsecase(this._speechRepository);

  final ISpeechRepository _speechRepository;

  @override
  Future<void> call() {
    return _speechRepository.resume();
  }
}
