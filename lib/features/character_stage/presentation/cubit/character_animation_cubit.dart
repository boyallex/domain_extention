import 'dart:async';

import 'package:domain_extention/features/character_stage/domain/entity/character_emotion.dart';
import 'package:domain_extention/features/character_stage/domain/entity/character_emotion_cue.dart';
import 'package:domain_extention/features/character_stage/domain/service/i_character_animation_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'character_animation_state.dart';

/// Контроллер анимаций персонажа + provider текущего/запланированного состояния.
/// UI (`Character2dStage`) слушает [state] и переключает спрайты лица/губ/руки.
class CharacterAnimationCubit extends Cubit<CharacterAnimationState>
    implements ICharacterAnimationController {
  CharacterAnimationCubit() : super(const CharacterAnimationState());

  Timer? _scheduledTimer;

  @override
  CharacterEmotion get current => state.current;

  @override
  CharacterEmotionCue? get scheduled => state.scheduled;

  @override
  void play(CharacterEmotion emotion) {
    _cancelTimer();
    emit(
      CharacterAnimationState(
        current: emotion,
        scheduled: null,
      ),
    );
  }

  @override
  void stop() {
    _cancelTimer();
    emit(const CharacterAnimationState());
  }

  @override
  void schedule(CharacterEmotion emotion, Duration delay) {
    if (delay <= Duration.zero) {
      play(emotion);
      return;
    }
    _cancelTimer();
    final cue = CharacterEmotionCue(emotion: emotion, delay: delay);
    emit(state.copyWith(scheduled: cue));
    _scheduledTimer = Timer(delay, () {
      if (isClosed) {
        return;
      }
      play(emotion);
    });
  }

  @override
  void applyCue(CharacterEmotionCue cue) {
    schedule(cue.emotion, cue.delay);
  }

  void _cancelTimer() {
    _scheduledTimer?.cancel();
    _scheduledTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
