abstract interface class ILiveConversationDatasource {
  Future<Object> connect(Object config);

  Stream<Object> events(Object session);

  Future<void> sendAudio(Object chunk);

  Future<void> interrupt(Object session);

  Future<void> disconnect(Object session);
}
