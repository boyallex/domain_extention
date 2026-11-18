import 'package:domain_extention/features/listening/domain/repository/i_speech_repository.dart';
import 'package:domain_extention/features/listening/domain/usecase/i_open_permission_settings_usecase.dart';

class OpenPermissionSettingsUsecase implements IOpenPermissionSettingsUsecase {
  const OpenPermissionSettingsUsecase(this._speechRepository);

  final ISpeechRepository _speechRepository;

  @override
  Future<bool> call({String target = 'auto'}) {
    return _speechRepository.openPermissionSettings(target: target);
  }
}
