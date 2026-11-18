import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';
import 'package:domain_extention/features/assistant/presentation/cubit/assistant_page_cubit.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/bubble.dart';
import 'package:flutter/material.dart';

/// Список сообщений чата (занимает доступную высоту родителя).
class AssistantChatList extends StatefulWidget {
  const AssistantChatList({
    super.key,
    required this.state,
    required this.controller,
    this.height,
    this.showAvatars = false,
    this.avatarAsset,
  });

  final AssistantPageState state;
  final ScrollController controller;
  final double? height;
  final bool showAvatars;
  final String? avatarAsset;

  @override
  State<AssistantChatList> createState() => _AssistantChatListState();
}

class _AssistantChatListState extends State<AssistantChatList> {
  @override
  void didUpdateWidget(covariant AssistantChatList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.partialText != widget.state.partialText ||
        oldWidget.state.messages.length != widget.state.messages.length ||
        oldWidget.state.isThinking != widget.state.isThinking) {
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = widget.controller;
      if (!controller.hasClients) {
        return;
      }
      controller.jumpTo(controller.position.minScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final live = widget.state.partialText.trim();
    final showLive = live.isNotEmpty;
    final hasAssistantPlaceholder =
        widget.state.messages.isNotEmpty &&
        widget.state.messages.last.role == 'assistant' &&
        widget.state.messages.last.busy;
    final showTyping =
        widget.state.isThinking && !showLive && !hasAssistantPlaceholder;
    final count =
        widget.state.messages.length +
        (showLive ? 1 : 0) +
        (showTyping ? 1 : 0);

    final list = count == 0
        ? const SizedBox.expand()
        : ListView.builder(
            controller: widget.controller,
            reverse: true,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: count,
            itemBuilder: (context, index) {
              final messageIndex = count - 1 - index;
              if (showTyping && messageIndex == count - 1) {
                return MessageBubble(
                  message: const ChatMessage(
                    role: 'assistant',
                    text: '',
                    busy: true,
                  ),
                  index: messageIndex,
                  showAvatar: widget.showAvatars,
                  avatarAsset: widget.avatarAsset,
                );
              }
              if (showLive &&
                  messageIndex == count - 1 - (showTyping ? 1 : 0)) {
                return MessageBubble(
                  message: ChatMessage(role: 'user', text: live),
                  index: messageIndex,
                  live: true,
                  showAvatar: widget.showAvatars,
                  avatarAsset: widget.avatarAsset,
                );
              }
              return MessageBubble(
                message: widget.state.messages[messageIndex],
                index: messageIndex,
                showAvatar: widget.showAvatars,
                avatarAsset: widget.avatarAsset,
              );
            },
          );

    if (widget.height != null) {
      return SizedBox(height: widget.height, child: list);
    }
    return list;
  }
}
