/// Unified error hierarchy for the app.
///
/// All provider-specific exceptions (DioError, FirebaseException, etc.)
/// MUST be translated into an AppException subtype at the data_source
/// boundary before propagating to repositories or BLoCs.
///
/// sealed requires all subtypes to be declared in this same library.
sealed class AppException {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  final String? code;

  const AppException({
    required this.message,
    this.cause,
    this.stackTrace,
    this.code,
  });

  /// A user-safe phrase suitable for display in the UI.
  String get localizedMessage;
}

/// Thrown when a network request fails (DNS, timeout, no connection, HTTP error).
final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.code,
  });

  @override
  String get localizedMessage =>
      'A network error occurred. Please check your connection and try again.';
}

/// Thrown when a Firestore operation fails.
final class FirestoreException extends AppException {
  const FirestoreException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.code,
  });

  @override
  String get localizedMessage =>
      'A database error occurred. Please try again later.';
}

/// Thrown when a Cloud Storage operation fails.
final class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.code,
  });

  @override
  String get localizedMessage =>
      'A file storage error occurred. Please try again.';
}

/// Thrown when an authentication operation fails.
///
/// [code] maps directly to a `FirebaseAuthException.code` value.
/// [localizedMessage] translates each known code to a user-facing phrase.
final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.code,
  });

  @override
  String get localizedMessage {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'user-not-found':
        return 'No account exists for this email.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'popup-closed-by-user':
        return 'Sign-in cancelled.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }
}

/// Thrown when caller-supplied input fails a precondition check.
final class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.code,
  });

  @override
  String get localizedMessage => message;
}

/// Thrown when no other subtype applies — wraps unexpected exceptions.
final class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.code,
  });

  @override
  String get localizedMessage =>
      'An unexpected error occurred. Please try again.';
}
