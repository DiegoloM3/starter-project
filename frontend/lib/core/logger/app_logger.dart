import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Single logging + crash-report surface for the whole app.
///
/// Keeps the project free of scattered `print()` calls and centralises
/// the points where a future Crashlytics / Sentry integration would hook in
/// (see analysis point R9). Until that integration lands, errors just
/// reach the dev console — but _every_ error goes through here.
abstract final class AppLogger {
  static const _channel = 'news_app';

  static void info(Object? message) {
    developer.log('$message', name: _channel);
  }

  static void warn(Object? message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      '$message',
      name: _channel,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Entry point for every caught exception.
  static void report(Object error, StackTrace? stackTrace) {
    developer.log(
      'Unhandled error',
      name: _channel,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Wraps `FlutterError.onError` so framework-level errors take the same
  /// path as zone-level ones.
  static void reportFlutterError(FlutterErrorDetails details) {
    FlutterError.presentError(details);
    report(details.exception, details.stack);
  }

  /// Wraps `PlatformDispatcher.instance.onError`. Returning true tells the
  /// platform the error has been handled.
  static bool reportPlatformError(Object error, StackTrace stackTrace) {
    report(error, stackTrace);
    return true;
  }
}
