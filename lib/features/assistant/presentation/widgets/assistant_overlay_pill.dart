import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_waveform_slot.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Компактный desktop overlay / widget pill (заготовка под system overlay).
class AssistantOverlayPill extends StatelessWidget {
  const AssistantOverlayPill({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.voiceLevel,
    required this.active,
    required this.onMicPressed,
    this.avatarAsset,
    this.onTap,
  });

  final String name;
  final String lastMessage;
  final double voiceLevel;
  final bool active;
  final VoidCallback onMicPressed;
  final String? avatarAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: GlassContainer(
          width: 320,
          height: 72,
          useOwnLayer: true,
          quality: GlassQuality.standard,
          settings: theme.controlSettings,
          shape: const LiquidRoundedRectangle(
            borderRadius: GlassDefaults.capsuleRadius,
          ),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: [
              _Avatar(asset: avatarAsset, name: name),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.stageBone,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3DDC84),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lastMessage.isEmpty ? 'Готов слушать' : lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.stageBone.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AssistantWaveformSlot(
                      level: voiceLevel,
                      active: active,
                      width: 120,
                      height: 14,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              GlassIconButton(
                icon: Icon(
                  active ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: SukunaTheme.bone,
                ),
                semanticLabel: 'Микрофон',
                onPressed: onMicPressed,
                size: 40,
                iconSize: 18,
                useOwnLayer: true,
                quality: GlassQuality.standard,
                settings: theme.controlSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.asset, required this.name});

  final String? asset;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    final letter = name.isNotEmpty ? name.substring(0, 1) : '?';

    return ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: asset != null && asset!.isNotEmpty
            ? Image.asset(asset!, fit: BoxFit.cover)
            : ColoredBox(
                color: theme.stageAccent.withValues(alpha: 0.55),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: theme.stageBone,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
