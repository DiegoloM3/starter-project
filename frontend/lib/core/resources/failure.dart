import 'package:equatable/equatable.dart';

/// Why an operation failed, expressed in domain terms.
///
/// The data layer translates transport-specific errors (Dio, Firebase, SQLite)
/// into one of these so the domain and presentation layers never depend on
/// those packages.
enum FailureType {
  /// No connectivity or the request timed out.
  network,

  /// The remote service answered with an error.
  server,

  /// The requested resource does not exist.
  notFound,

  /// The operation requires a signed-in user.
  unauthenticated,

  /// Email or password rejected by the identity provider.
  invalidCredentials,

  /// Sign-up attempted with an email that already has an account.
  emailAlreadyInUse,

  /// Password rejected as too weak by the identity provider.
  weakPassword,

  /// Security rules rejected the operation.
  permissionDenied,

  /// Input rejected by domain validation before reaching any service.
  validation,

  /// The user aborted the operation (e.g. closed the Google account picker).
  cancelled,

  /// Anything not covered above.
  unknown,
}

class Failure extends Equatable {
  final FailureType type;
  final String message;

  const Failure(this.type, this.message);

  const Failure.network([String message = 'No internet connection.'])
      : this(FailureType.network, message);

  const Failure.server([String message = 'The server could not complete the request.'])
      : this(FailureType.server, message);

  const Failure.notFound([String message = 'Not found.'])
      : this(FailureType.notFound, message);

  const Failure.unauthenticated([String message = 'You need to sign in first.'])
      : this(FailureType.unauthenticated, message);

  const Failure.invalidCredentials([String message = 'Wrong email or password.'])
      : this(FailureType.invalidCredentials, message);

  const Failure.emailAlreadyInUse(
      [String message = 'An account already exists for this email.'])
      : this(FailureType.emailAlreadyInUse, message);

  const Failure.weakPassword([String message = 'The password is too weak.'])
      : this(FailureType.weakPassword, message);

  const Failure.permissionDenied(
      [String message = 'You are not allowed to do that.'])
      : this(FailureType.permissionDenied, message);

  const Failure.validation(String message) : this(FailureType.validation, message);

  const Failure.cancelled([String message = 'Operation cancelled.'])
      : this(FailureType.cancelled, message);

  const Failure.unknown([String message = 'Something went wrong.'])
      : this(FailureType.unknown, message);

  @override
  List<Object?> get props => [type, message];

  @override
  String toString() => 'Failure(${type.name}: $message)';
}
