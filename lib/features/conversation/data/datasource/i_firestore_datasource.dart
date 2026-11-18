import 'package:domain_extention/features/conversation/domain/entity/conversation_message.dart';

abstract interface class IFirestoreDatasource {
  Future<List<ConversationMessage>> loadMessages({
    required String userId,
    required String characterId,
  });

  Future<void> appendMessage({
    required String userId,
    required String characterId,
    required ConversationMessage message,
  });
}
