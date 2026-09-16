import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';

/// Translates Firebase and Google Sign-In errors into domain [Failure]s so
/// nothing above the data layer knows those SDKs exist.
abstract final class FirebaseFailureMapper {
  static Failure map(Object error) {
    return switch (error) {
      FirebaseAuthException(:final code) => _fromAuthCode(code),
      FirebaseException(:final code) => _fromServiceCode(code),
      GoogleSignInException(:final code) => code == GoogleSignInExceptionCode.canceled
          ? const Failure.cancelled()
          : const Failure.unknown('Google sign-in did not complete.'),
      SocketException() => const Failure.network(),
      _ => const Failure.unknown(),
    };
  }

  static Failure _fromAuthCode(String code) {
    return switch (code) {
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' ||
      'invalid-email' ||
      'user-disabled' =>
        const Failure.invalidCredentials(),
      'email-already-in-use' => const Failure.emailAlreadyInUse(),
      'weak-password' => const Failure.weakPassword(),
      'network-request-failed' => const Failure.network(),
      'too-many-requests' => const Failure.server('Too many attempts. Try again in a moment.'),
      _ => const Failure.unknown(),
    };
  }

  static Failure _fromServiceCode(String code) {
    return switch (code) {
      'permission-denied' || 'unauthorized' => const Failure.permissionDenied(),
      'not-found' || 'object-not-found' => const Failure.notFound(),
      'unauthenticated' => const Failure.unauthenticated(),
      'unavailable' || 'deadline-exceeded' || 'retry-limit-exceeded' => const Failure.network(),
      'canceled' => const Failure.cancelled(),
      'resource-exhausted' => const Failure.server('The editor is busy. Try again in a moment.'),
      'invalid-argument' => const Failure.validation('The editor could not accept that text.'),
      _ => const Failure.server(),
    };
  }
}
