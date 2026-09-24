import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: 'AIzaSyDummyKey',
      appId: '1:123456789:android:abcdef123456',
      messagingSenderId: '123456789',
      projectId: 'demo-project',
      storageBucket: 'demo-project.appspot.com',
    );
  }
}

