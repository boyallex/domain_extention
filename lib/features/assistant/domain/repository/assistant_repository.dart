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
  Stream<String> reply({
    required String userText,
    List<ChatMessage> history = const [],
  }) async* {
    final uri = Uri.parse('${_secrets.llmBaseUrl}/chat/completions');
    final recent = history.length <= 6
        ? history
        : history.sublist(history.length - 6);

    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer ${_secrets.llmApiKey}',
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({
        'model': _secrets.llmModel,
        'temperature': 0.7,
        'max_tokens': 160,
        'stream': true,
        'messages': [
          {'role': 'system', 'content': _profile.prompt},
          ...recent.map(
            (message) => {'role': message.role, 'content': message.text},
          ),
          {'role': 'user', 'content': userText},
        ],
      });

    final response = await _client
        .send(request)
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      throw Exception('LLM ${response.statusCode}: $body');
    }

    var text = '';
    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .timeout(const Duration(seconds: 30));
    await for (final line in lines) {
      if (!line.startsWith('data:')) {
        continue;
      }
      final data = line.substring(5).trim();
      if (data.isEmpty || data == '[DONE]') {
        continue;
      }
      final json = jsonDecode(data) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        continue;
      }
      final delta = choices.first['delta'] as Map<String, dynamic>?;
      final piece = delta?['content'] as String?;
      if (piece == null || piece.isEmpty) {
        continue;
      }
      text += piece;
      yield text;
    }

    if (text.trim().isEmpty) {
      throw Exception('LLM empty stream');
    }
  }
}
