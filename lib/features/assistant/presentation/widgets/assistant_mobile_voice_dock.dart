import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_waveform_slot.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Voice-first нижняя панель mobile: waveform + mic + keyboard / menu.
class AssistantMobileVoiceDock extends StatelessWidget {
  const AssistantMobileVoiceDock({
    super.key,
    required this.listening,
    this.connecting = false,
    required this.speaking,
    required this.voiceLevel,
    required this.onToggleVoice,
    required this.onOpenKeyboard,
    required this.onOpenMenu,
  });

  final bool listening;
  final bool connecting;
  final bool speaking;
  final double voiceLevel;
  final VoidCallback onToggleVoice;
  final VoidCallback onOpenKeyboard;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    final active = listening || speaking;
    final glow = speaking ? theme.voiceOutboundColor : theme.voiceInboundColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AssistantWaveformSlot(
            level: voiceLevel,
            active: active,
            width: 180,
            height: 40,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GlassIconButton(
                icon: const Icon(
                  Icons.keyboard_rounded,
                  color: SukunaTheme.bone,
                ),
                semanticLabel: 'Клавиатура',
                onPressed: onOpenKeyboard,
                size: 48,
                iconSize: 22,
                useOwnLayer: true,
                quality: GlassQuality.standard,
                settings: theme.controlSettings,
              ),
              _MainMicButton(
                active: active,
                connecting: connecting,
                glow: glow,
                onPressed: onToggleVoice,
              ),
              GlassIconButton(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: SukunaTheme.bone,
                ),
                semanticLabel: 'Меню',
                onPressed: onOpenMenu,
                size: 48,
                iconSize: 24,
                useOwnLayer: true,
                quality: GlassQuality.standard,
                settings: theme.controlSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MainMicButton extends StatelessWidget {
  const _MainMicButton({
    required this.active,
    required this.connecting,
    required this.glow,
    required this.onPressed,
  });

  final bool active;
  final bool connecting;
  final Color glow;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: active ? 0.45 : 0.18),
            blurRadius: active ? 28 : 16,
            spreadRadius: active ? 2 : 0,
          ),
        ],
      ),
      child: GlassButton.custom(
        onTap: onPressed,
        enabled: !connecting,
        useOwnLayer: true,
        quality: GlassQuality.standard,
        settings: theme.controlSettings,
        shape: const LiquidOval(),
        child: SizedBox(
          width: 84,
          height: 84,
          child: Center(
            child: connecting
                ? const SizedBox.square(
                    dimension: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Icon(
                    active ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 34,
                    color: active ? glow : SukunaTheme.bone,
                  ),
          ),
        ),
      ),
    );
  }
}
