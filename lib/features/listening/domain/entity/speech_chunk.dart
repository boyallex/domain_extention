class SpeechChunk {
  const SpeechChunk({
    required this.text,
    required this.isFinal,
  });

  final String text;
  final bool isFinal;
}
