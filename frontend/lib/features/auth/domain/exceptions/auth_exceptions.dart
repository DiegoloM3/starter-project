import '../params/auth_validation.dart';

class AuthValidationException implements Exception {
  final Set<AuthValidationError> errors;

  const AuthValidationException(this.errors);
}
