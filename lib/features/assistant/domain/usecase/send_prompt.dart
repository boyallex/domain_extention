import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';
import 'package:domain_extention/features/assistant/domain/repository/i_assistant_repository.dart';
import 'package:domain_extention/features/assistant/domain/usecase/i_send_prompt.dart';

class SendPrompt implements ISendPrompt {
  const SendPrompt({required IAssistantRepository this._repository});

  final IAssistantRepository _repository;

  @override
  Future<ChatMessage> call(String userText) {
    return _repository.reply(userText: userText);
  }
}
