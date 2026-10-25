abstract interface class IClonedSpeechDatasource {
  Future<Object> registerVoice(Object sample);

  Future<Object> synthesize(Object utterance);
}
