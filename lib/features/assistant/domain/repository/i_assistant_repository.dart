import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';

abstract interface class IAssistantRepository {
  Future<ChatMessage> reply({
    required String userText,
    List<ChatMessage> history = const [],
  });
}
