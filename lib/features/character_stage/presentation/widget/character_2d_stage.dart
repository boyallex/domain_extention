import 'package:domain_extention/features/character_stage/domain/entity/character_emotion.dart';
import 'package:domain_extention/features/character_stage/domain/entity/character_sprite_pose.dart';
import 'package:domain_extention/features/character_stage/domain/service/character_sprite_animator.dart';
import 'package:domain_extention/features/character_stage/presentation/cubit/character_animation_cubit.dart';
import 'package:domain_extention/features/character_stage/presentation/widget/sprite_paint.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 2D-сцена: тело + смена головы/губ по эмоции (без слоя рук).
class Character2dStage extends StatefulWidget {
  const Character2dStage({
    super.key,
    this.atlas = sukunaSpriteAtlas,
  });

  final CharacterSpriteAtlas atlas;

  @override
  State<Character2dStage> createState() => _Character2dStageState();
}

class _Character2dStageState extends State<Character2dStage>
    with TickerProviderStateMixin {
  /// Доля ширины тела: вырезанная голова ~111px при теле ~440px.
  static const _headWidthFactor = 0.24;

  /// Центр лица на seated-теле (Alignment, Y: -1 сверху).
  static const _headAlignment = Alignment(0.0, -0.66);

  late final CharacterSpriteAnimator _animator;
  late final AnimationController _breath;
  late final Ticker _clock;

  SpriteAnimationTicker? _mouthTicker;
  var _ready = false;
  var _tick = 0;

  @override
  void initState() {
    super.initState();
    _animator = CharacterSpriteAnimator(atlas: widget.atlas);
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _clock = createTicker((_) {
      final ticker = _mouthTicker;
      if (ticker == null || ticker.done()) {
        return;
      }
      ticker.update(1 / 60);
      setState(() => _tick++);
      if (ticker.done()) {
        setState(() {});
      }
    })..start();
    _load();
  }

  Future<void> _load() async {
    await _animator.load();
    if (!mounted) {
      return;
    }
    setState(() => _ready = true);
  }

  void _onEmotion(CharacterEmotion emotion) {
    if (!_ready) {
      return;
    }
    _mouthTicker = _animator.mouthPulse(emotion).createTicker();
    setState(() => _tick++);
  }

  @override
  void dispose() {
    _clock.dispose();
    _breath.dispose();
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _animator.body == null) {
      return const SizedBox.expand();
    }

    return BlocConsumer<CharacterAnimationCubit, CharacterAnimationState>(
      listenWhen: (previous, current) => previous.current != current.current,
      listener: (context, state) => _onEmotion(state.current),
      builder: (context, state) {
        final pose = _animator.pose(state.current);
        final mouthSprite = _mouthTicker?.getSprite() ?? pose.mouth;
        final headSize = pose.head.srcSize;
        final headAspect = headSize.y / headSize.x;

        return AnimatedBuilder(
          animation: _breath,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_breath.value);
            final scale = 1.0 + (t - 0.5) * 0.015;

            return Transform.scale(
              scale: scale,
              alignment: const Alignment(0, 0.35),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final side = constraints.biggest.shortestSide;
                  final width = side * 0.88;
                  final height = width * 1.35;
                  final headW = width * _headWidthFactor;
                  final headH = headW * headAspect;
                  // Рот в нижней трети головы.
                  final mouthW = headW * 0.34;
                  final mouthH = mouthW * 0.45;

                  return Align(
                    alignment: const Alignment(0, 0.28),
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SpritePaint(sprite: _animator.body!),
                          Align(
                            alignment: _headAlignment,
                            child: SizedBox(
                              width: headW,
                              height: headH,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                child: SpritePaint(
                                  key: ValueKey(state.current),
                                  sprite: pose.head,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment(
                              _headAlignment.x,
                              _headAlignment.y + 0.12,
                            ),
                            child: SizedBox(
                              width: mouthW,
                              height: mouthH,
                              child: SpritePaint(
                                key: ValueKey('mouth-$_tick'),
                                sprite: mouthSprite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
