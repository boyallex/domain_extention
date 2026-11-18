import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';

abstract interface class IConversationRepository {
  Future<List<ChatMessage>> loadHistory({required String characterId});

  Future<void> saveMessage({
    required String characterId,
    required ChatMessage message,
  });
}
