import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Options from native Firebase configs already in the project.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase web is not configured.');
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      // macOS plist is not checked in yet; reuse iOS app for local runs.
      TargetPlatform.macOS => ios,
      _ => throw UnsupportedError(
        'Firebase is not configured for $defaultTargetPlatform.',
      ),
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB6JPksBD_LqkKbgrF-KSfuND8A06d2JAo',
    appId: '1:1059790606393:android:193bf201c569791f67fde8',
    messagingSenderId: '1059790606393',
    projectId: 'domain-extention',
    storageBucket: 'domain-extention.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQsaMrABZTT9AF3woIBr_nUAVzrkLmQHE',
    appId: '1:1059790606393:ios:19296c81da4cb21d67fde8',
    messagingSenderId: '1059790606393',
    projectId: 'domain-extention',
    storageBucket: 'domain-extention.firebasestorage.app',
    iosBundleId: 'com.example.domainExtention',
  );
}
