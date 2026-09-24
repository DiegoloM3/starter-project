/// Rule that a set of credentials breaks before it is ever sent anywhere.
///
/// Errors are reported as values instead of messages so that the presentation
/// layer stays in charge of wording and translating them.
enum CredentialsValidationError {
  emailRequired,
  emailMalformed,
  passwordRequired,
  passwordTooShort,
  passwordsDoNotMatch,
  displayNameInvalid,
}

/// Returned by the use cases when credentials do not satisfy their rules.
class CredentialsValidationException implements Exception {
  final List<CredentialsValidationError> errors;

  const CredentialsValidationException(this.errors);

  @override
  String toString() => 'CredentialsValidationException($errors)';
}

/// The address is already registered, so it cannot be signed up again.
class EmailAlreadyRegisteredException implements Exception {
  const EmailAlreadyRegisteredException();

  @override
  String toString() => 'EmailAlreadyRegisteredException()';
}

/// The email/password pair does not identify anybody.
///
/// Deliberately does not distinguish "no such account" from "wrong password":
/// telling them apart would let anyone find out who has an account here.
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();

  @override
  String toString() => 'InvalidCredentialsException()';
}

/// An operation that needs a signed in user ran without one.
class NotSignedInException implements Exception {
  const NotSignedInException();

  @override
  String toString() => 'NotSignedInException()';
}

/// The backend is refusing further attempts for now.
class TooManyAttemptsException implements Exception {
  const TooManyAttemptsException();

  @override
  String toString() => 'TooManyAttemptsException()';
}
