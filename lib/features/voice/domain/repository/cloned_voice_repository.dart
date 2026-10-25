import 'dart:convert';
import 'dart:typed_data';

import 'package:domain_extention/app/config/app_secrets.dart';
import 'package:domain_extention/app/profile/character_bundle.dart';
import 'package:domain_extention/features/voice/domain/entity/cloned_voice.dart';
import 'package:domain_extention/features/voice/domain/repository/i_cloned_voice_repository.dart';
import 'package:http/http.dart' as http;

class ClonedVoiceRepository implements IClonedVoiceRepository {
  ClonedVoiceRepository({
    required AppSecrets this._secrets,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final AppSecrets _secrets;
  final http.Client _client;

  @override
  Future<ClonedVoice> getByCharacterId(String characterId) async {
    final bundle = await CharacterBundle.loadSukuna();
    if (bundle.id != characterId) {
      throw Exception('Персонаж $characterId не найден');
    }

    return ClonedVoice(
      id: bundle.voiceRemoteId,
      characterId: bundle.id,
      remoteId: bundle.voiceRemoteId,
    );
  }

  @override
  Future<Uint8List> speak({
    required String text,
    required ClonedVoice voice,
  }) async {
    final bundle = await CharacterBundle.loadSukuna();
    final uri = Uri.parse(
      '${bundle.voiceApiBaseUrl}${bundle.voiceApiPath}',
    );

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${_secrets.voiceApiKey}',
        'Content-Type': 'application/json',
        'model': bundle.voiceModel,
      },
      body: jsonEncode({
        'text': text,
        'reference_id': voice.remoteId,
        'format': 'mp3',
        'normalize': true,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'TTS ${response.statusCode}: ${response.body}',
      );
    }

    return response.bodyBytes;
  }
}
