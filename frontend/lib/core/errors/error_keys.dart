/// Localization keys for error messages.
///
/// These keys are used by the domain layer (Failure objects) and are resolved
/// to user-friendly messages by the presentation layer using AppLocalizations.
/// This approach ensures no hardcoded English text in the error-handling logic.
///
/// **Usage in presentation:**
/// ```dart
/// case AuthError(:final failure):
///   showErrorDialog(context.l10n.getString(failure.message));
/// ```
library;

/// Authentication-related error keys.
abstract final class AuthErrorKeys {
  /// User account not found.
  static const String userNotFound = 'auth.userNotFound';

  /// Incorrect password.
  static const String wrongPassword = 'auth.wrongPassword';

  /// Invalid email address format.
  static const String invalidEmail = 'auth.invalidEmail';

  /// User account has been disabled.
  static const String userDisabled = 'auth.userDisabled';

  /// Email already associated with an account.
  static const String emailAlreadyInUse = 'auth.emailAlreadyInUse';

  /// Password does not meet security requirements.
  static const String weakPassword = 'auth.weakPassword';

  /// Authentication method is not enabled.
  static const String operationNotAllowed = 'auth.operationNotAllowed';

  /// User cancelled the authentication flow.
  static const String userCancelled = 'auth.userCancelled';

  /// User session has expired.
  static const String tokenExpired = 'auth.tokenExpired';

  /// Invalid credentials provided.
  static const String invalidCredentials = 'auth.invalidCredentials';

  /// Generic authentication error.
  static const String generic = 'auth.generic';
}

/// Server/API-related error keys.
abstract final class ServerErrorKeys {
  /// Generic server error.
  static const String generic = 'server.generic';

  /// Resource not found (404).
  static const String notFound = 'server.notFound';

  /// User is not authorized (401).
  static const String unauthorized = 'server.unauthorized';

  /// User does not have permission (403).
  static const String forbidden = 'server.forbidden';

  /// Bad request (400).
  static const String badRequest = 'server.badRequest';

  /// Too many requests (429).
  static const String tooManyRequests = 'server.tooManyRequests';

  /// Internal server error (500).
  static const String internalError = 'server.internalError';

  /// Bad gateway (502).
  static const String badGateway = 'server.badGateway';

  /// Service unavailable (503).
  static const String serviceUnavailable = 'server.serviceUnavailable';

  /// Failed to create user profile in Firestore.
  static const String profileCreationFailed = 'server.profileCreationFailed';
}

/// Network-related error keys.
abstract final class NetworkErrorKeys {
  /// No internet connection available.
  static const String noConnection = 'network.noConnection';

  /// Network request timed out.
  static const String timeout = 'network.timeout';

  /// Generic network error.
  static const String generic = 'network.generic';
}

/// Local cache/database error keys.
abstract final class CacheErrorKeys {
  /// Generic local database error.
  static const String generic = 'cache.generic';

  /// Requested item not found in local database.
  static const String notFound = 'cache.notFound';

  /// Failed to write to local database.
  static const String writeError = 'cache.writeError';
}
