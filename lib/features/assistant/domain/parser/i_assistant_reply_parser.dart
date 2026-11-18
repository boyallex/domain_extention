import 'package:domain_extention/features/assistant/domain/entity/assistant_reply_payload.dart';

abstract interface class IAssistantReplyParser {
  /// Разбирает сырой ответ модели (JSON эмоции + текст) в payload.
  AssistantReplyPayload parse(String raw);
}
