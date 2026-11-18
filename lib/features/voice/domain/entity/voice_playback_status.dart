import 'dart:typed_data';

class VoicePlaybackStatus {
  const VoicePlaybackStatus({
    required this.isPlaying,
    required this.isCompleted,
    required this.position,
    required this.duration,
    this.currentBytes,
  });

  final bool isPlaying;
  final bool isCompleted;
  final Duration position;
  final Duration duration;
  final Uint8List? currentBytes;
}
