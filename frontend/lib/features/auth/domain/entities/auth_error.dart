enum AuthError {
  wrongEmailOrPassword,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  tooManyAttempts,
  noConnection,
  unknown,
}

/// Thrown when Firebase Authentication rejects a request, already translated to the business errors above.
class AuthException implements Exception {
  final AuthError error;

  const AuthException(this.error);

  @override
  String toString() => 'AuthException($error)';
}
