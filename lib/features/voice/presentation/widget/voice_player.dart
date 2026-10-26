import 'dart:async';
import 'dart:typed_data';

import 'package:domain_extention/app/theme/sukuna_theme.dart';
import 'package:domain_extention/features/voice/presentation/widget/bytes_audio_source.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class VoicePlayer extends StatefulWidget {
  const VoicePlayer({
    super.key,
    required this.bytes,
    this.autoplay = true,
  });

  final Uint8List bytes;
  final bool autoplay;

  @override
  State<VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<VoicePlayer> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _ready = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final duration = await _player.setAudioSource(
        BytesAudioSource(widget.bytes),
      );
      _positionSub = _player.positionStream.listen((position) {
        if (mounted) setState(() => _position = position);
      });
      if (!mounted) return;
      setState(() {
        _duration = duration ?? Duration.zero;
        _ready = true;
      });
      if (widget.autoplay) await _player.play();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    unawaited(_positionSub?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }

  String _format(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Text(
        'Плеер не открыл звук',
        style: TextStyle(color: SukunaTheme.blood.withValues(alpha: 0.9)),
      );
    }

    final totalMs = _duration.inMilliseconds;
    final value = totalMs == 0
        ? 0.0
        : (_position.inMilliseconds / totalMs).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SukunaTheme.ash,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SukunaTheme.blood.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: SukunaTheme.blood,
                        foregroundColor: SukunaTheme.bone,
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: !_ready
                          ? null
                          : () {
                              if (playing) {
                                unawaited(_player.pause());
                              } else {
                                unawaited(_player.play());
                              }
                            },
                      icon: Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 28,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: !_ready
                      ? null
                      : () => unawaited(_player.seek(Duration.zero)),
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
                          onChanged: !_ready || totalMs == 0
                              ? null
                              : (next) {
                                  unawaited(
                                    _player.seek(
                                      Duration(
                                        milliseconds: (next * totalMs).round(),
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _format(_position),
                              style: const TextStyle(
                                color: SukunaTheme.bone,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              _format(_duration),
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
          ],
        ),
      ),
    );
  }
}
