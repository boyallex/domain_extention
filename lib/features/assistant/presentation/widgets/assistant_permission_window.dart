import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/assistant/presentation/cubit/assistant_page_cubit.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_permission_line.dart';
import 'package:flutter/material.dart';

class AssistantPermissionWindow extends StatelessWidget {
  const AssistantPermissionWindow({
    super.key,
    required this.cubit,
    required this.state,
  });

  final AssistantPageCubit cubit;
  final AssistantPageState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 32,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SukunaTheme.ash,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: SukunaTheme.blood.withValues(alpha: 0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.mic_off_rounded, color: SukunaTheme.blood),
                const SizedBox(height: 12),
                const Text(
                  'Нужен доступ к голосу',
                  style: TextStyle(
                    color: SukunaTheme.bone,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                AssistantPermissionLine(
                  ok: state.hasMicrophone,
                  label: 'Микрофон',
                ),
                const SizedBox(height: 6),
                AssistantPermissionLine(
                  ok: state.hasSpeech,
                  label: 'Распознавание речи',
                ),
                const SizedBox(height: 12),
                Text(
                  _hint(state),
                  style: TextStyle(
                    color: SukunaTheme.bone.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: cubit.openPermissionSettings,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SukunaTheme.bone,
                          side: BorderSide(
                            color: SukunaTheme.bone.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text('Настройки'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: cubit.requestPermission,
                        style: FilledButton.styleFrom(
                          backgroundColor: SukunaTheme.blood,
                          foregroundColor: SukunaTheme.bone,
                        ),
                        child: const Text('Разрешить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _hint(AssistantPageState state) {
  if (!state.hasSpeech && state.hostedByFlutter) {
    return 'Тумблер в Настройках macOS не выдаёт API-право. Из Cursor/flutter run запрос речи роняет приложение. Запусти из Xcode, нажми «Разрешить» и подтверди системный диалог один раз. После этого можно снова из терминала.';
  }
  if (!state.hasSpeech) {
    return 'Тумблер в Настройках не считается выдачей. Нажми «Разрешить» — должен появиться системный диалог распознавания речи.';
  }
  return 'Речь уже есть, микрофон — нет. Нажми «Разрешить» для запроса микрофона.';
}
