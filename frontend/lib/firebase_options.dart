import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está soportado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4hO8fzQbxb4Zy7bBgNsBev-KWuqUGf2o',
    appId: '1:560559933172:android:d074879538471a81f480a1',
    messagingSenderId: '560559933172',
    projectId: 'tortutip-mvp',
    storageBucket: 'tortutip-mvp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRrT0JWMSL8WVzNN8IZXTDfA1TXNaZXBA',
    appId: '1:560559933172:ios:911b0a161eff1c61f480a1',
    messagingSenderId: '560559933172',
    projectId: 'tortutip-mvp',
    storageBucket: 'tortutip-mvp.firebasestorage.app',
    iosBundleId: 'com.tortutip.tortutip',
  );
}
