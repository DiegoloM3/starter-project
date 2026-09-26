import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

const firebaseFirestoreDatabaseId = 'articles';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS Firebase configuration is not provisioned for this project.');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS Firebase configuration is not provisioned for this project.');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows Firebase configuration is not provisioned for this project.');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux Firebase configuration is not provisioned for this project.');
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Fuchsia Firebase configuration is not provisioned for this project.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDizYe6ugvQZu1bAbpxYv5-AfQkKGvidtY',
    appId: '1:779268956923:web:2f835d79af9dad177e465e',
    messagingSenderId: '779268956923',
    projectId: 'case-study-symmetry',
    authDomain: 'case-study-symmetry.firebaseapp.com',
    storageBucket: 'case-study-symmetry.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmUusxng4efUjPTIgGgvpX0D44XYq5fSU',
    appId: '1:779268956923:android:5049fc3657403c707e465e',
    messagingSenderId: '779268956923',
    projectId: 'case-study-symmetry',
    storageBucket: 'case-study-symmetry.firebasestorage.app',
  );
}
