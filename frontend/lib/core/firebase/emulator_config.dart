import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
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
      FirebaseFirestore.instance.useFirestoreEmulator(host, _firestorePort);
      await FirebaseStorage.instance.useStorageEmulator(host, _storagePort);
    }
  }
}
