import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';
import 'package:domain_extention/features/assistant/domain/repository/i_assistant_repository.dart';
import 'package:domain_extention/features/assistant/domain/usecase/i_send_message_usecase.dart';

class SendMessageUsecase implements ISendMessageUsecase {
  SendMessageUsecase(this._assistantRepository);

  final IAssistantRepository _assistantRepository;

  @override
  Stream<String> call({
    required String userText,
    List<ChatMessage> history = const [],
  }) {
    return _assistantRepository.reply(
      userText: userText,
      history: history,
    );
  }
}
