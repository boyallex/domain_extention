import 'dart:async';

import 'package:domain_extention/app/app.dart';
import 'package:domain_extention/app/config/app_secrets.dart';
import 'package:domain_extention/app/config/firebase_options.dart';
import 'package:domain_extention/app/di/injection.dart';
import 'package:domain_extention/core/log/log_service.dart';
import 'package:domain_extention/app/profile/character_bundle.dart';
import 'package:domain_extention/app/profile/sukuna_profile.dart';
import 'package:domain_extention/app/theme/app_theme.dart';
import 'package:domain_extention/features/assistant/domain/repository/assistant_repository.dart';
import 'package:domain_extention/features/listening/data/datasource/speech_to_text_datasource.dart';
import 'package:domain_extention/features/listening/domain/repository/speech_repository.dart';
import 'package:domain_extention/features/voice/domain/repository/voice_playback.dart';
import 'package:domain_extention/features/voice/domain/repository/voice_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final secrets = AppSecrets.fromEnv();
  final profile = await SukunaProfile.load();
  final bundle = await CharacterBundle.loadSukuna();
  const log = LogService();
  final speechDatasource = SpeechToTextDatasource(log: log);

  setupDependencies(
    theme: AppTheme(),
    logService: log,
    characterId: profile.id,
    assistantRepository: AssistantRepository(
      secrets: secrets,
      profile: profile,
    ),
    voiceRepository: VoiceRepository(
      secrets: secrets,
      bundle: bundle,
    ),
    speechRepository: SpeechRepository(
      datasource: speechDatasource,
    ),
    voicePlayback: VoicePlayback(),
  );

  unawaited(speechDatasource.warmUp());
  runApp(const App());
}
