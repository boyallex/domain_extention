abstract interface class ILiveAssistantDatasource {
  Future<Object> connect(Object config);

  Future<Object> callTool(Object request);
}
