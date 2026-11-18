import 'package:domain_extention/app/theme/i_app_theme.dart';
import 'package:domain_extention/core/log/i_log_service.dart';
import 'package:domain_extention/core/log/log_service.dart';
import 'package:domain_extention/features/assistant/domain/parser/assistant_reply_parser.dart';
import 'package:domain_extention/features/assistant/domain/parser/i_assistant_reply_parser.dart';
import 'package:domain_extention/features/assistant/domain/repository/i_assistant_repository.dart';
import 'package:domain_extention/features/assistant/domain/usecase/answer_message_usecase.dart';
import 'package:domain_extention/features/assistant/domain/usecase/i_answer_message_usecase.dart';
import 'package:domain_extention/features/assistant/domain/usecase/i_send_message_usecase.dart';
import 'package:domain_extention/features/assistant/domain/usecase/send_message_usecase.dart';
import 'package:domain_extention/features/assistant/presentation/cubit/assistant_page_cubit.dart';
import 'package:domain_extention/features/listening/domain/repository/i_speech_repository.dart';
import 'package:domain_extention/features/listening/domain/usecase/i_open_permission_settings_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/i_start_session_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/i_stop_session_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/open_permission_settings_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/start_session_usecase.dart';
import 'package:domain_extention/features/listening/domain/usecase/stop_session_usecase.dart';
import 'package:domain_extention/features/character_stage/domain/repository/character_stage_catalog.dart';
import 'package:domain_extention/features/character_stage/domain/repository/i_character_stage_catalog.dart';
import 'package:domain_extention/features/character_stage/domain/service/i_character_animation_controller.dart';
import 'package:domain_extention/features/character_stage/presentation/cubit/character_animation_cubit.dart';
import 'package:domain_extention/features/character_stage/presentation/cubit/character_stage_cubit.dart';
import 'package:domain_extention/features/conversation/data/datasource/device_user_id_store.dart';
import 'package:domain_extention/features/conversation/data/datasource/firestore_datasource.dart';
import 'package:domain_extention/features/conversation/data/datasource/i_firestore_datasource.dart';
import 'package:domain_extention/features/conversation/domain/repository/conversation_repository.dart';
import 'package:domain_extention/features/conversation/domain/repository/i_conversation_repository.dart';
import 'package:domain_extention/features/voice/domain/repository/i_voice_playback.dart';
import 'package:domain_extention/features/voice/domain/repository/i_voice_repository.dart';
import 'package:domain_extention/features/voice/domain/usecase/i_toggle_playback_usecase.dart';
import 'package:domain_extention/features/voice/domain/usecase/toggle_playback_usecase.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies({
  required IAssistantRepository assistantRepository,
  required IVoiceRepository voiceRepository,
  required ISpeechRepository speechRepository,
  required IVoicePlayback voicePlayback,
  required IAppTheme theme,
  required String characterId,
  IConversationRepository? conversationRepository,
  ILogService? logService,
}) {
  getIt
    ..registerSingleton<ILogService>(logService ?? const LogService())
    ..registerSingleton<IAppTheme>(theme)
    ..registerSingleton<IAssistantRepository>(assistantRepository)
    ..registerSingleton<IVoiceRepository>(voiceRepository)
    ..registerSingleton<ISpeechRepository>(speechRepository)
    ..registerSingleton<IVoicePlayback>(voicePlayback)
    ..registerSingleton<ICharacterStageCatalog>(const CharacterStageCatalog())
    ..registerLazySingleton(
      () => CharacterStageCubit(catalog: getIt<ICharacterStageCatalog>()),
    )
    ..registerLazySingleton<CharacterAnimationCubit>(
      CharacterAnimationCubit.new,
    )
    ..registerLazySingleton<ICharacterAnimationController>(
      () => getIt<CharacterAnimationCubit>(),
    )
    ..registerSingleton<IAssistantReplyParser>(const AssistantReplyParser())
    ..registerSingleton<DeviceUserIdStore>(const DeviceUserIdStore())
    ..registerLazySingleton<IFirestoreDatasource>(FirestoreDatasource.new)
    ..registerLazySingleton<IConversationRepository>(
      () =>
          conversationRepository ??
          ConversationRepository(
            datasource: getIt<IFirestoreDatasource>(),
            userId: getIt<DeviceUserIdStore>().getOrCreate,
          ),
    )
    ..registerLazySingleton<ISendMessageUsecase>(
      () => SendMessageUsecase(getIt<IAssistantRepository>()),
    )
    ..registerLazySingleton<IAnswerMessageUsecase>(
      () => AnswerMessageUsecase(getIt<IVoiceRepository>()),
    )
    ..registerLazySingleton<IStartSessionUsecase>(
      () => StartSessionUsecase(getIt<ISpeechRepository>()),
    )
    ..registerLazySingleton<IStopSessionUsecase>(
      () => StopSessionUsecase(getIt<ISpeechRepository>()),
    )
    ..registerSingleton<ITogglePlaybackUsecase>(const TogglePlaybackUsecase())
    ..registerLazySingleton<IOpenPermissionSettingsUsecase>(
      () => OpenPermissionSettingsUsecase(getIt<ISpeechRepository>()),
    )
    ..registerLazySingleton(
      () => AssistantPageCubit(
        sendMessage: getIt<ISendMessageUsecase>(),
        answerMessage: getIt<IAnswerMessageUsecase>(),
        startSession: getIt<IStartSessionUsecase>(),
        stopSession: getIt<IStopSessionUsecase>(),
        togglePlayback: getIt<ITogglePlaybackUsecase>(),
        openPermissionSettings: getIt<IOpenPermissionSettingsUsecase>(),
        speechRepository: getIt<ISpeechRepository>(),
        playback: getIt<IVoicePlayback>(),
        replyParser: getIt<IAssistantReplyParser>(),
        animationController: getIt<ICharacterAnimationController>(),
        conversation: getIt<IConversationRepository>(),
        characterId: characterId,
        log: getIt<ILogService>(),
      ),
    );
}
