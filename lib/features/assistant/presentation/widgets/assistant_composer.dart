import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_glass_field.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_mic_button.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_send_button.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_voice_orb.dart';
import 'package:flutter/material.dart';

/// Нижняя панель: текст+микрофон или голосовой круг.
class AssistantComposer extends StatelessWidget {
  const AssistantComposer({
    super.key,
    required this.controller,
    required this.listening,
    required this.connecting,
    required this.loading,
    required this.speaking,
    required this.voiceLevel,
    required this.onToggleVoice,
    required this.onSubmit,
    this.forceText = false,
  });

  final TextEditingController controller;
  final bool listening;
  final bool connecting;
  final bool loading;
  final bool speaking;
  final double voiceLevel;
  final VoidCallback onToggleVoice;
  final VoidCallback onSubmit;
  final bool forceText;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    final voiceMode = !forceText && (listening || speaking);

    return Padding(
      padding: theme.controlMargin,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: voiceMode
            ? AssistantVoiceOrb(
                key: const ValueKey('voice'),
                listening: listening,
                speaking: speaking,
                level: voiceLevel,
                onPressed: onToggleVoice,
              )
            : Row(
                key: const ValueKey('text'),
                children: [
                  AssistantMicButton(
                    listening: listening,
                    connecting: connecting,
                    onPressed: onToggleVoice,
                  ),
                  SizedBox(width: theme.controlGap),
                  Expanded(
                    child: AssistantGlassField(
                      controller: controller,
                      hintText: 'Написать сообщение...',
                      onSubmitted: onSubmit,
                    ),
                  ),
                  SizedBox(width: theme.controlGap),
                  AssistantSendButton(
                    loading: loading,
                    onPressed: onSubmit,
                  ),
                ],
              ),
      ),
    );
  }
}
