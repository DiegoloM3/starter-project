import '../params/auth_validation.dart';

class AuthValidationException implements Exception {
  final Set<AuthValidationError> errors;

  const AuthValidationException(this.errors);
}

/// The email or the password is wrong. It does not say which one, so accounts cannot be guessed.
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

class EmailAlreadyInUseException implements Exception {
  const EmailAlreadyInUseException();
}
