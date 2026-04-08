import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

import '../../firebase_options.dart';

/// Initializes Firebase and (in debug mode) wires every client to the local
/// Firebase Emulator Suite.
///
/// Android emulator reaches the host machine at `10.0.2.2`; everything else
/// (iOS simulator, web, desktop) uses `localhost`.
class FirebaseEmulatorBootstrap {
  static const _authPort = 9099;
  static const _firestorePort = 8080;
  static const _storagePort = 9199;

  static String get _emulatorHost {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kDebugMode) {
      final host = _emulatorHost;
      await FirebaseAuth.instance.useAuthEmulator(host, _authPort);
      FirebaseFirestore.instance.useFirestoreEmulator(host, _firestorePort);
      await FirebaseStorage.instance.useStorageEmulator(host, _storagePort);
    }

    // Anonymous sign-in: every install gets a stable Firebase UID without
    // forcing a registration flow. The UID is used as the document `uid` for
    // every published article.
    //
    // Workaround for firebase_auth 4.16.0 Pigeon decoding bug
    // (https://github.com/firebase/flutterfire/issues/12274): the native iOS
    // plugin returns a payload shape the Dart side cannot decode, but the
    // sign-in itself completes. We catch the cast error and verify the result
    // via `currentUser`.
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } on TypeError catch (_) {
        // Pigeon decode failure — the sign-in actually completed.
      }
      // Wait briefly for the auth state to propagate after the workaround.
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.authStateChanges().firstWhere((u) => u != null);
      }
    }
  }
}
