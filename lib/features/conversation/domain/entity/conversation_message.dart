class ConversationMessage {
  const ConversationMessage({
    required this.role,
    required this.text,
    required this.createdAt,
    this.id,
  });

  final String? id;
  final String role;
  final String text;
  final DateTime createdAt;
}
