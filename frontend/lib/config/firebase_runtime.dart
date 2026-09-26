import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';
import 'firebase_web_emulator_marker.dart'
    if (dart.library.js_interop) 'firebase_web_emulator_marker_web.dart'
    as web_emulator_marker;

const useFirebaseEmulator = bool.fromEnvironment(
  'USE_FIREBASE_EMULATOR',
  defaultValue: false,
);
const firebaseEmulatorHost = String.fromEnvironment(
  'FIREBASE_EMULATOR_HOST',
  defaultValue: '127.0.0.1',
);

Future<void> configureFirebaseRuntime() async {
  if (!useFirebaseEmulator) return;
  // Configure every provider immediately after initializeApp and before DI accesses it.
  // firebase_auth_web may skip reconnection when a stale debug-only marker is
  // present in sessionStorage. Release builds do not restore that marker.
  if (kIsWeb) web_emulator_marker.clearAuthEmulatorMarker();
  await FirebaseAuth.instance.useAuthEmulator(firebaseEmulatorHost, 9099);
  FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: firebaseFirestoreDatabaseId,
  ).useFirestoreEmulator(firebaseEmulatorHost, 8080);
  await FirebaseStorage.instance.useStorageEmulator(firebaseEmulatorHost, 9199);
}
