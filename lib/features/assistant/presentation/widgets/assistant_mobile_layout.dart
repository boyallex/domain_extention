import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/assistant/presentation/cubit/assistant_page_cubit.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_chat_list.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_composer.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_mobile_voice_dock.dart';
import 'package:domain_extention/features/shell/presentation/widget/character_name_chip.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AssistantMobileLayout extends StatelessWidget {
  const AssistantMobileLayout({
    super.key,
    required this.state,
    required this.characterName,
    required this.avatarAsset,
    required this.scrollController,
    required this.inputController,
    required this.textMode,
    required this.onCharacterTap,
    required this.onHomeTap,
    required this.onToggleVoice,
    required this.onSubmit,
    required this.onOpenKeyboard,
    required this.onCloseKeyboard,
    required this.onOpenMenu,
  });

  final AssistantPageState state;
  final String characterName;
  final String? avatarAsset;
  final ScrollController scrollController;
  final TextEditingController inputController;
  final bool textMode;
  final VoidCallback onCharacterTap;
  final VoidCallback onHomeTap;
  final VoidCallback onToggleVoice;
  final VoidCallback onSubmit;
  final VoidCallback onOpenKeyboard;
  final VoidCallback onCloseKeyboard;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    final chatHeight = (MediaQuery.sizeOf(context).height * 0.24)
        .clamp(140.0, 220.0)
        .toDouble();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              CharacterNameChip(
                name: characterName,
                avatarAsset: avatarAsset,
                onTap: onCharacterTap,
              ),
              const Spacer(),
              GlassIconButton(
                icon: const Icon(Icons.home_rounded, color: SukunaTheme.bone),
                semanticLabel: 'Дом',
                onPressed: onHomeTap,
                size: theme.iconButtonSize + 6,
                iconSize: theme.iconGlyphSize,
                useOwnLayer: true,
                quality: GlassQuality.standard,
                settings: theme.controlSettings,
              ),
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: chatHeight,
              child: AssistantChatList(
                state: state,
                controller: scrollController,
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: textMode
              ? Column(
                  key: const ValueKey('text-dock'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 4),
                        child: TextButton.icon(
                          onPressed: onCloseKeyboard,
                          icon: Icon(
                            Icons.mic_rounded,
                            size: 18,
                            color: theme.stageBone.withValues(alpha: 0.7),
                          ),
                          label: Text(
                            'Голос',
                            style: TextStyle(
                              color: theme.stageBone.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AssistantComposer(
                      controller: inputController,
                      listening: state.isListening && !state.isSpeaking,
                      connecting: state.isConnecting,
                      loading: state.isLoading,
                      speaking: state.isSpeaking,
                      voiceLevel: state.voiceLevel,
                      onToggleVoice: onToggleVoice,
                      onSubmit: onSubmit,
                      forceText: true,
                    ),
                  ],
                )
              : AssistantMobileVoiceDock(
                  key: const ValueKey('voice-dock'),
                  listening: state.isListening && !state.isSpeaking,
                  connecting: state.isConnecting,
                  speaking: state.isSpeaking,
                  voiceLevel: state.voiceLevel,
                  onToggleVoice: onToggleVoice,
                  onOpenKeyboard: onOpenKeyboard,
                  onOpenMenu: onOpenMenu,
                ),
        ),
      ],
    );
  }
}
