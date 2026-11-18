import 'dart:typed_data';

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.audio,
    this.audioSegments,
    this.busy = false,
  });

  final String role;
  final String text;
  final Uint8List? audio;
  final List<Uint8List>? audioSegments;
  final bool busy;

  ChatMessage copyWith({
    String? role,
    String? text,
    Uint8List? audio,
    List<Uint8List>? audioSegments,
    bool? busy,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      text: text ?? this.text,
      audio: audio ?? this.audio,
      audioSegments: audioSegments ?? this.audioSegments,
      busy: busy ?? this.busy,
    );
  }
}
