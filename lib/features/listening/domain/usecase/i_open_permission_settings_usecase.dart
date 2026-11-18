abstract interface class IOpenPermissionSettingsUsecase {
  Future<bool> call({String target = 'auto'});
}
