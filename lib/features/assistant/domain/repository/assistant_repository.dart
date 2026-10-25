import 'dart:convert';

import 'package:domain_extention/app/config/app_secrets.dart';
import 'package:domain_extention/app/profile/i_character_profile.dart';
import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';
import 'package:domain_extention/features/assistant/domain/repository/i_assistant_repository.dart';
import 'package:http/http.dart' as http;

class AssistantRepository implements IAssistantRepository {
  AssistantRepository({
    required AppSecrets this._secrets,
    required ICharacterProfile this._profile,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final AppSecrets _secrets;
  final ICharacterProfile _profile;
  final http.Client _client;

  @override
  Future<ChatMessage> reply({
    required String userText,
    List<ChatMessage> history = const [],
  }) async {
    final uri = Uri.parse('${_secrets.llmBaseUrl}/chat/completions');
    final recent = history.length <= 6
        ? history
        : history.sublist(history.length - 6);

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${_secrets.llmApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _secrets.llmModel,
        'temperature': 0.7,
        'max_tokens': 120,
        'messages': [
          {'role': 'system', 'content': _profile.prompt},
          ...recent.map(
            (message) => {'role': message.role, 'content': message.text},
          ),
          {'role': 'user', 'content': userText},
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'LLM ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>;
    final message = choices.first['message'] as Map<String, dynamic>;

    return ChatMessage(
      role: 'assistant',
      text: (message['content'] as String).trim(),
    );
  }
}
