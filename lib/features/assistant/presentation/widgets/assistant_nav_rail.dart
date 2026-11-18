import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

enum AssistantNavDestination { chat, home, display, settings }

/// Левый сайдбар desktop: Чат / Дом / Дисплей / Настройки.
class AssistantNavRail extends StatelessWidget {
  const AssistantNavRail({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final AssistantNavDestination selected;
  final ValueChanged<AssistantNavDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    return GlassContainer(
      width: 84,
      useOwnLayer: true,
      quality: GlassQuality.standard,
      settings: theme.controlSettings,
      shape: const LiquidRoundedRectangle(borderRadius: 28),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Column(
        children: [
          _NavItem(
            icon: Icons.chat_bubble_rounded,
            label: 'Чат',
            selected: selected == AssistantNavDestination.chat,
            onTap: () => onSelect(AssistantNavDestination.chat),
          ),
          const SizedBox(height: 14),
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Дом',
            selected: selected == AssistantNavDestination.home,
            onTap: () => onSelect(AssistantNavDestination.home),
          ),
          const SizedBox(height: 14),
          _NavItem(
            icon: Icons.desktop_windows_rounded,
            label: 'Дисплей',
            selected: selected == AssistantNavDestination.display,
            onTap: () => onSelect(AssistantNavDestination.display),
          ),
          const Spacer(),
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'Настройки',
            selected: selected == AssistantNavDestination.settings,
            onTap: () => onSelect(AssistantNavDestination.settings),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();
    final color = selected
        ? theme.stageBone
        : theme.stageBone.withValues(alpha: 0.55);

    return Material(
      color: selected
          ? theme.stageAccent.withValues(alpha: 0.28)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
