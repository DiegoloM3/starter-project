import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// The app uses the Firebase Local Emulator Suite by default, because Cloud Storage requires
/// the Blaze plan on a real project (backend/README.md). Run with
/// `--dart-define=USE_FIREBASE_EMULATORS=false` to use the real Firebase project instead.
const bool _useFirebaseEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS', defaultValue: true);

/// Host of the emulators as seen from the device. On the Android emulator, FlutterFire maps
/// 127.0.0.1 to 10.0.2.2 (the computer); on a phone, `adb reverse` makes 127.0.0.1 reach it.
const String _emulatorsHost = String.fromEnvironment('FIREBASE_EMULATORS_HOST', defaultValue: '127.0.0.1');

const int _authEmulatorPort = 9099;
const int _firestoreEmulatorPort = 8080;
const int _storageEmulatorPort = 9199;

Future<void> connectToFirebaseEmulatorsIfEnabled() async {
  if (!_useFirebaseEmulators) return;
  await FirebaseAuth.instance.useAuthEmulator(_emulatorsHost, _authEmulatorPort);
  FirebaseFirestore.instance.useFirestoreEmulator(_emulatorsHost, _firestoreEmulatorPort);
  await FirebaseStorage.instance.useStorageEmulator(_emulatorsHost, _storageEmulatorPort);
}
