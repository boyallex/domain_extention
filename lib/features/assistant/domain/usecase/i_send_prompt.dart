import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';

abstract interface class ISendPrompt {
  Future<ChatMessage> call(String userText);
}
