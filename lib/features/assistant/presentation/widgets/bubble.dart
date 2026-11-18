import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/assistant/domain/entity/chat_message.dart';
import 'package:flutter/material.dart';

/// Текст сообщения без фоновой плашки.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.index,
    this.live = false,
    this.showAvatar = false,
    this.avatarAsset,
  });

  final ChatMessage message;
  final int index;
  final bool live;
  final bool showAvatar;
  final String? avatarAsset;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    final mine = message.role == 'user';
    final text = message.busy && message.text.isEmpty
        ? 'Думает...'
        : message.text;

    if (text.isEmpty && !message.busy) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: message.busy && message.text.isEmpty
                ? const _TypingDots()
                : Text(
                    text,
                    style: TextStyle(
                      color: theme.stageBone.withValues(
                        alpha: live ? 0.72 : 0.92,
                      ),
                      fontSize: 14.5,
                      height: 1.35,
                      fontStyle: live ? FontStyle.italic : FontStyle.normal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_controller.value + i * 0.2) % 1.0;
            final lift = (phase < 0.5 ? phase : 1 - phase) * 4;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -lift),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.stageBone.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
