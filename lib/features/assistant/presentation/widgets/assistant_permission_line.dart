import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:flutter/material.dart';

class AssistantPermissionLine extends StatelessWidget {
  const AssistantPermissionLine({
    super.key,
    required this.ok,
    required this.label,
  });

  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 18,
          color: ok ? const Color(0xFF7DCF8A) : SukunaTheme.blood,
        ),
        const SizedBox(width: 8),
        Text(
          ok ? '$label: есть' : '$label: нет',
          style: const TextStyle(color: SukunaTheme.bone),
        ),
      ],
    );
  }
}
