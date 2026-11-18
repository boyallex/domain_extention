import 'package:domain_extention/features/assistant/presentation/cubit/assistant_page_cubit.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_chat_list.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_desktop_composer.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_nav_rail.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_overlay_pill.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_side_panel.dart';
import 'package:domain_extention/features/shell/presentation/widget/character_name_chip.dart';
import 'package:flutter/material.dart';

/// Desktop: сайдбар | чат | умный дом.
class AssistantDesktopLayout extends StatelessWidget {
  const AssistantDesktopLayout({
    super.key,
    required this.state,
    required this.characterName,
    required this.avatarAsset,
    required this.scrollController,
    required this.inputController,
    required this.navDestination,
    required this.onNavSelect,
    required this.onCharacterTap,
    required this.onToggleVoice,
    required this.onSubmit,
    this.showOverlayPreview = false,
  });

  final AssistantPageState state;
  final String characterName;
  final String? avatarAsset;
  final ScrollController scrollController;
  final TextEditingController inputController;
  final AssistantNavDestination navDestination;
  final ValueChanged<AssistantNavDestination> onNavSelect;
  final VoidCallback onCharacterTap;
  final VoidCallback onToggleVoice;
  final VoidCallback onSubmit;
  final bool showOverlayPreview;

  @override
  Widget build(BuildContext context) {
    String? lastAssistant;
    for (final message in state.messages.reversed) {
      if (message.role != 'user' && message.text.isNotEmpty) {
        lastAssistant = message.text;
        break;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AssistantNavRail(
            selected: navDestination,
            onSelect: onNavSelect,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CharacterNameChip(
                    name: characterName,
                    avatarAsset: avatarAsset,
                    onTap: onCharacterTap,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: navDestination == AssistantNavDestination.chat
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final chatHeight = (constraints.maxHeight * 0.32)
                                .clamp(130.0, 260.0)
                                .toDouble();
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                height: chatHeight,
                                child: AssistantChatList(
                                  state: state,
                                  controller: scrollController,
                                ),
                              ),
                            );
                          },
                        )
                      : _DesktopSectionStub(destination: navDestination),
                ),
                if (navDestination == AssistantNavDestination.chat)
                  AssistantDesktopComposer(
                    controller: inputController,
                    listening: state.isListening && !state.isSpeaking,
                    connecting: state.isConnecting,
                    loading: state.isLoading,
                    onToggleVoice: onToggleVoice,
                    onSubmit: onSubmit,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            children: [
              const Expanded(child: AssistantSidePanel()),
              if (showOverlayPreview) ...[
                const SizedBox(height: 12),
                AssistantOverlayPill(
                  name: characterName,
                  lastMessage: lastAssistant ?? state.partialText,
                  voiceLevel: state.voiceLevel,
                  active: state.isListening || state.isSpeaking,
                  avatarAsset: avatarAsset,
                  onMicPressed: onToggleVoice,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DesktopSectionStub extends StatelessWidget {
  const _DesktopSectionStub({required this.destination});

  final AssistantNavDestination destination;

  @override
  Widget build(BuildContext context) {
    final labels = {
      AssistantNavDestination.home: 'Дом',
      AssistantNavDestination.display: 'Дисплей',
      AssistantNavDestination.settings: 'Настройки',
      AssistantNavDestination.chat: 'Чат',
    };
    return Center(
      child: Text(
        '${labels[destination]} — скоро',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
