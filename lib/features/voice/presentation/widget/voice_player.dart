import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/assistant/presentation/cubit/assistant_page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VoicePlayer extends StatelessWidget {
  const VoicePlayer({
    super.key,
    required this.messageIndex,
  });

  final int messageIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssistantPageCubit, AssistantPageState>(
      buildWhen: (previous, current) {
        final relevant = previous.playingMessageIndex == messageIndex ||
            current.playingMessageIndex == messageIndex;
        if (!relevant) {
          return false;
        }
        return previous.isPlaying != current.isPlaying ||
            previous.playbackPosition != current.playbackPosition ||
            previous.playbackDuration != current.playbackDuration ||
            previous.playingMessageIndex != current.playingMessageIndex;
      },
      builder: (context, state) {
        final cubit = context.read<AssistantPageCubit>();
        final mine = state.isActivePlayer(messageIndex);
        final playing = mine && state.isPlaying;
        final position = mine ? state.playbackPosition : Duration.zero;
        final duration = mine ? state.playbackDuration : Duration.zero;
        final totalMs = duration.inMilliseconds;
        final value = totalMs == 0
            ? 0.0
            : (position.inMilliseconds / totalMs).clamp(0.0, 1.0);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: SukunaTheme.ash,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: SukunaTheme.blood.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 16, 8),
            child: Row(
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: SukunaTheme.blood,
                    foregroundColor: SukunaTheme.bone,
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: () => cubit.togglePlayback(messageIndex),
                  icon: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => cubit.replay(messageIndex),
                  color: SukunaTheme.bone,
                  icon: const Icon(Icons.replay_rounded),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: SukunaTheme.blood,
                          inactiveTrackColor: SukunaTheme.bone.withValues(
                            alpha: 0.15,
                          ),
                          thumbColor: SukunaTheme.bone,
                        ),
                        child: Slider(
                          value: value,
                          onChanged: null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _format(position),
                              style: const TextStyle(
                                color: SukunaTheme.bone,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              _format(duration),
                              style: TextStyle(
                                color: SukunaTheme.bone.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _format(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
