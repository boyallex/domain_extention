import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  const AppSecrets({
    required this.llmApiKey,
    required this.llmBaseUrl,
    required this.llmModel,
    required this.voiceApiKey,
  });

  final String llmApiKey;
  final String llmBaseUrl;
  final String llmModel;
  final String voiceApiKey;

  factory AppSecrets.fromEnv() {
    return AppSecrets(
      llmApiKey: dotenv.env['LLM_API_KEY'] ?? '',
      llmBaseUrl:
          dotenv.env['LLM_BASE_URL'] ?? 'https://api.openai.com/v1',
      llmModel: dotenv.env['LLM_MODEL'] ?? 'gpt-4o-mini',
      voiceApiKey: dotenv.env['VOICE_API_KEY'] ?? '',
    );
  }
}
