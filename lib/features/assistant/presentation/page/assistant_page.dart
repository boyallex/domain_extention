import 'dart:async';

import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/assistant/presentation/cubit/assistant_page_cubit.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_desktop_layout.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_glass_scope.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_mobile_layout.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_nav_rail.dart';
import 'package:domain_extention/features/assistant/presentation/widgets/assistant_permission_window.dart';
import 'package:domain_extention/features/character_stage/presentation/cubit/character_stage_cubit.dart';
import 'package:domain_extention/features/character_stage/presentation/widget/character_stage.dart';
import 'package:domain_extention/features/shell/presentation/layout/assistant_breakpoints.dart';
import 'package:domain_extention/features/shell/presentation/widget/character_picker_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage>
    with WidgetsBindingObserver {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  var _pickerOpen = false;
  var _mobileTextMode = false;
  var _nav = AssistantNavDestination.chat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<AssistantPageCubit>().retryPermission());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _submit(AssistantPageCubit cubit) {
    cubit.sendMessage(_input.text);
    _input.clear();
  }

  void _showMobileMenu(BuildContext context) {
    final theme = const SukunaTheme();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.stageInk.withValues(alpha: 0.92),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.home_rounded, color: theme.stageBone),
                  title: Text(
                    'Дом',
                    style: TextStyle(color: theme.stageBone),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(
                    Icons.desktop_windows_rounded,
                    color: theme.stageBone,
                  ),
                  title: Text(
                    'Дисплей',
                    style: TextStyle(color: theme.stageBone),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.settings_rounded, color: theme.stageBone),
                  title: Text(
                    'Настройки',
                    style: TextStyle(color: theme.stageBone),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AssistantGlassScope(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<CharacterStageCubit, CharacterStageState>(
          builder: (context, stage) {
            return BlocBuilder<AssistantPageCubit, AssistantPageState>(
              buildWhen: (previous, current) =>
                  previous.messages != current.messages ||
                  previous.state != current.state ||
                  previous.partialText != current.partialText ||
                  previous.isError != current.isError ||
                  previous.needsPermission != current.needsPermission ||
                  previous.hasMicrophone != current.hasMicrophone ||
                  previous.hasSpeech != current.hasSpeech ||
                  previous.hostedByFlutter != current.hostedByFlutter ||
                  previous.sessionActive != current.sessionActive ||
                  previous.isConnecting != current.isConnecting ||
                  previous.isPlaying != current.isPlaying,
              builder: (context, state) {
                final cubit = context.read<AssistantPageCubit>();
                final stageCubit = context.read<CharacterStageCubit>();

                if (state.needsPermission) {
                  return AssistantPermissionWindow(cubit: cubit, state: state);
                }

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CharacterStage(profile: stage.selected),
                    SafeArea(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final desktop = AssistantBreakpoints.isDesktop(
                            constraints.maxWidth,
                          );
                          if (desktop) {
                            return AssistantDesktopLayout(
                              state: state,
                              characterName: stage.selected.name,
                              avatarAsset: stage.selected.figureAsset,
                              scrollController: _scroll,
                              inputController: _input,
                              navDestination: _nav,
                              onNavSelect: (value) {
                                setState(() => _nav = value);
                              },
                              onCharacterTap: () {
                                setState(() => _pickerOpen = !_pickerOpen);
                              },
                              onToggleVoice: cubit.toggleDialog,
                              onSubmit: () => _submit(cubit),
                            );
                          }

                          return AssistantMobileLayout(
                            state: state,
                            characterName: stage.selected.name,
                            avatarAsset: stage.selected.figureAsset,
                            scrollController: _scroll,
                            inputController: _input,
                            textMode: _mobileTextMode,
                            onCharacterTap: () {
                              setState(() => _pickerOpen = !_pickerOpen);
                            },
                            onHomeTap: () {
                              // Заглушка раздела «Дом» на mobile.
                            },
                            onToggleVoice: cubit.toggleDialog,
                            onSubmit: () => _submit(cubit),
                            onOpenKeyboard: () {
                              setState(() => _mobileTextMode = true);
                            },
                            onCloseKeyboard: () {
                              setState(() => _mobileTextMode = false);
                            },
                            onOpenMenu: () => _showMobileMenu(context),
                          );
                        },
                      ),
                    ),
                    if (_pickerOpen)
                      CharacterPickerMenu(
                        currentId: stage.selected.id,
                        catalog: stage.catalog,
                        onSelect: stageCubit.select,
                        onDismiss: () {
                          setState(() => _pickerOpen = false);
                        },
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
