sealed class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});
}

final class InvalidEmailException extends AuthException {
  const InvalidEmailException()
      : super(message: 'The email address is not valid.');
}

final class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super(message: 'The email address is already in use.');
}

final class UserDisabledException extends AuthException {
  const UserDisabledException()
      : super(message: 'This user account has been disabled.');
}

final class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super(message: 'No user found for that email.');
}

final class WrongPasswordException extends AuthException {
  const WrongPasswordException()
      : super(message: 'Incorrect password provided.');
}

final class TooManyRequestsException extends AuthException {
  const TooManyRequestsException()
      : super(message: 'Too many attempts. Please try again later.');
}

final class UserTokenExpiredException extends AuthException {
  const UserTokenExpiredException()
      : super(message: 'Session expired. Please log in again.');
}

final class NetworkRequestFailedException extends AuthException {
  const NetworkRequestFailedException()
      : super(message: 'Network error. Check your internet connection.');
}

final class InvalidCredentialException extends AuthException {
  const InvalidCredentialException()
      : super(message: 'Invalid login credentials provided.');
}

final class OperationNotAllowedException extends AuthException {
  const OperationNotAllowedException()
      : super(message: 'Email/Password accounts are not enabled.');
}

final class UnknownAuthException extends AuthException {
  final dynamic originalError;

  const UnknownAuthException({
    required String message,
    required this.originalError,
  }) : super(
          message: message,
        );
}
