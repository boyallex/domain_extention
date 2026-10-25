import 'package:domain_extention/features/voice/domain/entity/speech_turn.dart';
import 'package:domain_extention/features/voice/domain/entity/voice_session.dart';

abstract interface class ISpeechSessionRepository {
  Future<VoiceSession> start(String characterId);

  Stream<SpeechTurn> listen(VoiceSession session);

  Future<void> interrupt(VoiceSession session);

  Future<void> stop(VoiceSession session);
}
