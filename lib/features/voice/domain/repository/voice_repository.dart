import 'dart:convert';
import 'dart:typed_data';

import 'package:domain_extention/app/config/app_secrets.dart';
import 'package:domain_extention/app/profile/character_bundle.dart';
import 'package:domain_extention/features/voice/domain/repository/i_voice_repository.dart';
import 'package:http/http.dart' as http;

class VoiceRepository implements IVoiceRepository {
  VoiceRepository({
    required AppSecrets this._secrets,
    required CharacterBundle this._bundle,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final AppSecrets _secrets;
  final CharacterBundle _bundle;
  final http.Client _client;

  @override
  Future<Uint8List> speak(String text) async {
    final uri = Uri.parse('${_bundle.voiceApiBaseUrl}${_bundle.voiceApiPath}');

    final response = await _client
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer ${_secrets.voiceApiKey}',
            'Content-Type': 'application/json',
            'model': _bundle.voiceModel,
          },
          body: jsonEncode({
            'text': text,
            'reference_id': _bundle.voiceRemoteId,
            'format': 'mp3',
            'latency': 'balanced',
            'normalize': false,
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'TTS ${response.statusCode} reference_id=${_bundle.voiceRemoteId}: ${response.body}',
      );
    }

    return response.bodyBytes;
  }
}
