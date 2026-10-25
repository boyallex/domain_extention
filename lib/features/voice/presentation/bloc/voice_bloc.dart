import 'package:domain_extention/features/voice/presentation/bloc/voice_event.dart';
import 'package:domain_extention/features/voice/presentation/bloc/voice_state.dart';

abstract class VoiceBloc {
  const VoiceBloc();

  void add(VoiceEvent event);

  Stream<VoiceState> get stream;
}
