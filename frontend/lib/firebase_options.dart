// Hand-written Firebase options for the local emulator suite.
// The Firebase emulator does NOT validate these against a real Google Cloud
// project — only the projectId must be consistent. The other fields are
// placeholders required by the Firebase SDK to construct a valid options
// object.
//
// Note: the iOS Firebase SDK validates the format of `appId`, so it must
// look like a real Firebase app ID even though it points to nothing.
//
// This file is intentionally NOT generated via `flutterfire configure` because
// the project does not have (and does not need) a real Firebase project for
// the exercise.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return _web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      default:
        return _ios;
    }
  }

  static const _android = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789012:android:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'demo-news-app',
    storageBucket: 'demo-news-app.appspot.com',
  );

  static const _ios = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789012:ios:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'demo-news-app',
    storageBucket: 'demo-news-app.appspot.com',
    iosBundleId: 'com.example.frontend',
  );

  static const _web = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789012:web:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'demo-news-app',
    storageBucket: 'demo-news-app.appspot.com',
  );
}
