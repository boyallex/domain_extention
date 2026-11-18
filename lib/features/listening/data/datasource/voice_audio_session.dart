import 'package:audio_session/audio_session.dart';

/// Configures the native audio route for simultaneous speech capture/output.
class VoiceAudioSession {
  VoiceAudioSession({this.session});

  final AudioSession? session;
  Future<void>? _configuration;

  Future<void> activate() async {
    final audioSession = session ?? await AudioSession.instance;
    _configuration ??= audioSession.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions(0xC),
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
      ),
    );
    await _configuration;
    await audioSession.setActive(true);
  }

  Future<void> deactivate() async {
    final audioSession = session ?? await AudioSession.instance;
    await audioSession.setActive(false);
  }
}
