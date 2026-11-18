import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

/// Persistent anonymous device id used as Firestore user key until auth exists.
class DeviceUserIdStore {
  const DeviceUserIdStore();

  static const _fileName = 'device_user_id';

  /// Shared across instances so concurrent first-launch callers get one id.
  static Future<String>? _inFlight;
  static String? _cached;

  Future<String> getOrCreate() async {
    final cached = _cached;
    if (cached != null) {
      return cached;
    }
    return _inFlight ??= _loadOrCreate().whenComplete(() {
      _inFlight = null;
    });
  }

  Future<String> _loadOrCreate() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/$_fileName');
    if (await file.exists()) {
      final existing = (await file.readAsString()).trim();
      if (existing.isNotEmpty) {
        _cached = existing;
        return existing;
      }
    }
    final id = _newId();
    await file.parent.create(recursive: true);
    await file.writeAsString(id);
    _cached = id;
    return id;
  }

  String _newId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
