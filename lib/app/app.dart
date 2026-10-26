import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/assistant/domain/repository/i_assistant_repository.dart';
import 'package:domain_extention/features/assistant/presentation/page/assistant_page.dart';
import 'package:domain_extention/features/voice/domain/repository/i_cloned_voice_repository.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.assistantRepository,
    required this.voiceRepository,
  });

  final IAssistantRepository assistantRepository;
  final IClonedVoiceRepository voiceRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Domain Extention',
      debugShowCheckedModeBanner: false,
      theme: const SukunaTheme().dark,
      home: AssistantPage(
        assistantRepository: assistantRepository,
        voiceRepository: voiceRepository,
      ),
    );
  }
}
