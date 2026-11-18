import 'dart:io';

import 'package:domain_extention/features/listening/domain/entity/speech_permission.dart';
import 'package:flutter/services.dart';

class MacPermissionChannel {
  MacPermissionChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('domain_extention/permissions');

  final MethodChannel _channel;

  bool get isSupported => Platform.isMacOS;

  Future<SpeechPermission> status() async {
    if (!isSupported) {
      return const SpeechPermission(microphone: false, speech: false);
    }
    final status = await _channel.invokeMapMethod<String, dynamic>('status');
    return SpeechPermission(
      microphone: status?['microphone'] == true,
      speech: status?['speech'] == true,
      speechStatus: status?['speechStatus'] as String? ?? '',
      hostedByFlutter: status?['hostedByFlutter'] == true,
    );
  }

  Future<bool> hasPermission() async {
    return (await status()).isGranted;
  }

  Future<bool> request() async {
    if (!isSupported) {
      return false;
    }
    return await _channel.invokeMethod<bool>('request') ?? false;
  }

  Future<bool> openSettings({String target = 'auto'}) async {
    if (!isSupported) {
      return false;
    }
    return await _channel.invokeMethod<bool>('openSettings', target) ?? false;
  }
}
