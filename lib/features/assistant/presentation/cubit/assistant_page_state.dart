// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'assistant_page_cubit.dart';

const _unset = Object();

class AssistantPageState {
  const AssistantPageState({
    required this.messages,
    this.state = AssistantPageStateEnum.idle,
    this.isError = false,
    this.needsPermission = false,
    this.hasMicrophone = false,
    this.hasSpeech = false,
    this.hostedByFlutter = false,
    this.partialText = '',
    this.sessionActive = false,
    this.isConnecting = false,
    this.isPlaying = false,
    this.playbackPosition = Duration.zero,
    this.playbackDuration = Duration.zero,
    this.playingMessageIndex,
    this.voiceLevel = 0,
  });

  final List<ChatMessage> messages;
  final bool isError;
  final bool needsPermission;
  final bool hasMicrophone;
  final bool hasSpeech;
  final bool hostedByFlutter;
  final AssistantPageStateEnum state;
  final String partialText;
  final bool sessionActive;
  final bool isConnecting;
  final bool isPlaying;
  final Duration playbackPosition;
  final Duration playbackDuration;
  final int? playingMessageIndex;
  final double voiceLevel;

  bool get isIdle => state == AssistantPageStateEnum.idle;
  bool get isLoading => state == AssistantPageStateEnum.sending;
  bool get isListening => sessionActive;
  bool get isThinking =>
      isLoading || (messages.isNotEmpty && messages.last.busy);
  bool get isSpeaking => isPlaying;

  bool isActivePlayer(int messageIndex) => playingMessageIndex == messageIndex;

  AssistantPageState copyWith({
    List<ChatMessage>? messages,
    bool? isError,
    bool? needsPermission,
    bool? hasMicrophone,
    bool? hasSpeech,
    bool? hostedByFlutter,
    AssistantPageStateEnum? state,
    String? partialText,
    bool? sessionActive,
    bool? isConnecting,
    bool? isPlaying,
    Duration? playbackPosition,
    Duration? playbackDuration,
    Object? playingMessageIndex = _unset,
    double? voiceLevel,
  }) {
    return AssistantPageState(
      messages: messages ?? this.messages,
      isError: isError ?? this.isError,
      needsPermission: needsPermission ?? this.needsPermission,
      hasMicrophone: hasMicrophone ?? this.hasMicrophone,
      hasSpeech: hasSpeech ?? this.hasSpeech,
      hostedByFlutter: hostedByFlutter ?? this.hostedByFlutter,
      state: state ?? this.state,
      partialText: partialText ?? this.partialText,
      sessionActive: sessionActive ?? this.sessionActive,
      isConnecting: isConnecting ?? this.isConnecting,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      playbackDuration: playbackDuration ?? this.playbackDuration,
      playingMessageIndex: identical(playingMessageIndex, _unset)
          ? this.playingMessageIndex
          : playingMessageIndex as int?,
      voiceLevel: voiceLevel ?? this.voiceLevel,
    );
  }
}

final class AssistantPageInitial extends AssistantPageState {
  const AssistantPageInitial() : super(messages: const []);
}
