import 'package:domain_extention/app/di/injection.dart';
import 'package:domain_extention/app/theme/i_app_theme.dart';
import 'package:domain_extention/features/assistant/presentation/cubit/assistant_page_cubit.dart';
import 'package:domain_extention/features/assistant/presentation/page/assistant_page.dart';
import 'package:domain_extention/features/character_stage/presentation/cubit/character_animation_cubit.dart';
import 'package:domain_extention/features/character_stage/presentation/cubit/character_stage_cubit.dart';
import 'package:domain_extention/features/character_stage/presentation/widget/app_stage_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = getIt<IAppTheme>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AssistantPageCubit>()),
        BlocProvider.value(value: getIt<CharacterStageCubit>()),
        BlocProvider.value(value: getIt<CharacterAnimationCubit>()),
      ],
      child: ListenableBuilder(
        listenable: theme,
        builder: (context, _) {
          return MaterialApp(
            title: 'Domain Extention',
            debugShowCheckedModeBanner: false,
            theme: theme.light,
            darkTheme: theme.dark,
            themeMode: ThemeMode.dark,
            builder: (context, child) {
              return AppStageBackground(child: child);
            },
            home: const AssistantPage(),
          );
        },
      ),
    );
  }
}
