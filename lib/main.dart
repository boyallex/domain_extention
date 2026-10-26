import 'package:domain_extention/app/app.dart';
import 'package:domain_extention/app/config/app_secrets.dart';
import 'package:domain_extention/app/profile/sukuna_profile.dart';
import 'package:domain_extention/features/assistant/domain/repository/assistant_repository.dart';
import 'package:domain_extention/features/voice/domain/repository/cloned_voice_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final secrets = AppSecrets.fromEnv();
  final profile = await SukunaProfile.load();

  runApp(
    App(
      assistantRepository: AssistantRepository(
        secrets: secrets,
        profile: profile,
      ),
      voiceRepository: ClonedVoiceRepository(secrets: secrets),
    ),
  );
}
