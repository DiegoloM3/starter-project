import 'package:firebase_core/firebase_core.dart';
import 'package:news_app_clean_architecture/core/errors/network_exception.dart';

extension FirebaseExceptionExtensions on FirebaseException {
  NetworkException get parse => switch (code) {
        'permission-denied' => NetworkForbiddenException(originalError: this),
        'unauthenticated' => NetworkUnauthorizedException(originalError: this),
        'not-found' => NetworkNotFoundException(originalError: this),
        'deadline-exceeded' => NetworkTimeoutException(
            message: 'Firestore request timed out',
            originalError: this,
          ),
        'unavailable' => NetworkServerException(
            originalError: this,
          ),
        'already-exists' => NetworkConflictException(originalError: this),
        _ => NetworkUnknownException(
            message: message ?? 'A Firebase error occurred',
            originalError: this,
          ),
      };
}
