import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:news_app_clean_architecture/app.dart';
import 'package:news_app_clean_architecture/core/logger/app_logger.dart';
import 'package:news_app_clean_architecture/firebase_options.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

/// Application entry point shared across flavors.
///
/// Responsibilities (kept tiny on purpose):
///   1. Bind the Flutter engine.
///   2. Initialise Firebase with the generated platform options.
///   3. Register cross-cutting error handlers.
///   4. Wire DI via [initializeDependencies]. Once Firebase is up,
///      `injection_container.dart` detects it via `Firebase.apps.isNotEmpty`
///      and binds the real Firestore/Storage repository instead of the fake.
///   5. Hand control over to [MyApp] inside a guarded zone.
Future<void> bootstrap() async {
  FlutterError.onError = AppLogger.reportFlutterError;
  PlatformDispatcher.instance.onError = AppLogger.reportPlatformError;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await initializeDependencies();

      runApp(const MyApp());
    },
    AppLogger.report,
  );
}
