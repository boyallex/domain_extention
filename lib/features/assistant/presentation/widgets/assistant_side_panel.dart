import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Правая desktop-панель: умный дом + дисплеи (UI-заглушки).
class AssistantSidePanel extends StatefulWidget {
  const AssistantSidePanel({super.key});

  @override
  State<AssistantSidePanel> createState() => _AssistantSidePanelState();
}

class _AssistantSidePanelState extends State<AssistantSidePanel> {
  var _light = true;
  var _ac = true;
  var _outlets = false;
  var _humidifier = true;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    return GlassContainer(
      width: 280,
      useOwnLayer: true,
      quality: GlassQuality.standard,
      settings: theme.controlSettings,
      shape: const LiquidRoundedRectangle(borderRadius: 28),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Умный дом',
            style: TextStyle(
              color: theme.stageBone,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _DeviceTile(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Свет в гостиной',
            value: _light,
            onChanged: (v) => setState(() => _light = v),
          ),
          _DeviceTile(
            icon: Icons.ac_unit_rounded,
            title: 'Кондиционер',
            subtitle: '24°C',
            value: _ac,
            onChanged: (v) => setState(() => _ac = v),
          ),
          _DeviceTile(
            icon: Icons.power_rounded,
            title: 'Розетки',
            value: _outlets,
            onChanged: (v) => setState(() => _outlets = v),
          ),
          _DeviceTile(
            icon: Icons.water_drop_outlined,
            title: 'Увлажнитель',
            value: _humidifier,
            onChanged: (v) => setState(() => _humidifier = v),
          ),
          const SizedBox(height: 18),
          Text(
            'Дисплеи',
            style: TextStyle(
              color: theme.stageBone,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _DisplayCard(
                  title: 'Гостиная TV',
                  icon: Icons.tv_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _DisplayCard(
                  title: 'Кабинет',
                  icon: Icons.desktop_mac_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: theme.stageBone.withValues(alpha: 0.75), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.stageBone,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: theme.stageBone.withValues(alpha: 0.45),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeThumbColor: theme.stageBone,
                activeTrackColor: const Color(0xFF7B5CFF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisplayCard extends StatelessWidget {
  const _DisplayCard({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = const SukunaTheme();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: AspectRatio(
        aspectRatio: 1.15,
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                size: 36,
                color: theme.stageBone.withValues(alpha: 0.35),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.stageBone.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 22,
                color: theme.stageBone.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
