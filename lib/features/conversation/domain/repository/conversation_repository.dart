import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';
import 'package:domain_extention/features/conversation/data/datasource/i_firestore_datasource.dart';
import 'package:domain_extention/features/conversation/domain/entity/conversation_message.dart';
import 'package:domain_extention/features/conversation/domain/repository/i_conversation_repository.dart';

class ConversationRepository implements IConversationRepository {
  ConversationRepository({
    required this._datasource,
    required this._userId,
  });

  final IFirestoreDatasource _datasource;
  final Future<String> Function() _userId;

  @override
  Future<List<ChatMessage>> loadHistory({required String characterId}) async {
    final userId = await _userId();
    final messages = await _datasource.loadMessages(
      userId: userId,
      characterId: characterId,
    );
    return [
      for (final message in messages)
        ChatMessage(role: message.role, text: message.text),
    ];
  }

  @override
  Future<void> saveMessage({
    required String characterId,
    required ChatMessage message,
  }) async {
    final text = message.text.trim();
    if (text.isEmpty || message.busy) {
      return;
    }
    if (message.role != 'user' && message.role != 'assistant') {
      return;
    }
    final userId = await _userId();
    await _datasource.appendMessage(
      userId: userId,
      characterId: characterId,
      message: ConversationMessage(
        role: message.role,
        text: text,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }
}
