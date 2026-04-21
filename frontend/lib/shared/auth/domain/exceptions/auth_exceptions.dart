sealed class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('The email or password is incorrect.');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('An account already exists with that email.');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super('Password must be at least 6 characters.');
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException() : super('Email address is not valid.');
}

class AuthUnknownException extends AuthException {
  const AuthUnknownException(super.message);
}
