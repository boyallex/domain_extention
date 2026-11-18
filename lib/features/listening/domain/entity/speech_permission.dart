class SpeechPermission {
  const SpeechPermission({
    required this.microphone,
    required this.speech,
    this.speechStatus = '',
    this.hostedByFlutter = false,
  });

  final bool microphone;
  final bool speech;
  final String speechStatus;
  final bool hostedByFlutter;

  bool get isGranted => microphone && speech;
}
