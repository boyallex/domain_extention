import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Нижний pill-input desktop: +, поле, микрофон, send.
class AssistantDesktopComposer extends StatelessWidget {
  const AssistantDesktopComposer({
    super.key,
    required this.controller,
    required this.listening,
    this.connecting = false,
    required this.loading,
    required this.onToggleVoice,
    required this.onSubmit,
    this.onAttach,
  });

  final TextEditingController controller;
  final bool listening;
  final bool connecting;
  final bool loading;
  final VoidCallback onToggleVoice;
  final VoidCallback onSubmit;
  final VoidCallback? onAttach;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Row(
        children: [
          GlassIconButton(
            icon: const Icon(Icons.add_rounded, color: SukunaTheme.bone),
            semanticLabel: 'Вложение',
            onPressed: onAttach ?? () {},
            size: 44,
            iconSize: 22,
            useOwnLayer: true,
            quality: GlassQuality.standard,
            settings: theme.controlSettings,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GlassContainer(
              height: 48,
              useOwnLayer: true,
              quality: GlassQuality.standard,
              settings: theme.controlSettings,
              shape: const LiquidRoundedRectangle(
                borderRadius: GlassDefaults.capsuleRadius,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                        color: SukunaTheme.bone,
                        fontSize: 15,
                      ),
                      cursorColor: SukunaTheme.bone,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSubmit(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Написать сообщение...',
                        hintStyle: TextStyle(
                          color: SukunaTheme.bone.withValues(alpha: 0.38),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: connecting ? null : onToggleVoice,
                    tooltip: connecting
                        ? 'Подключение микрофона'
                        : listening
                        ? 'Стоп'
                        : 'Микрофон',
                    icon: connecting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            listening
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            color: listening
                                ? theme.voiceOutboundColor
                                : SukunaTheme.bone.withValues(alpha: 0.75),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GlassIconButton(
            onPressed: loading ? null : onSubmit,
            size: 44,
            iconSize: 20,
            useOwnLayer: true,
            quality: GlassQuality.standard,
            settings: theme.controlSettings,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.send_rounded,
                    color: SukunaTheme.bone,
                  ),
          ),
        ],
      ),
    );
  }
}
