part of 'sign_in_cubit.dart';

enum SignInStatus { editing, submitting, success, failure }

class SignInState extends Equatable {
  final String email;
  final String password;
  final bool obscurePassword;
  final SignInStatus status;

  /// Field-level problems found on submit, cleared as the user types.
  final CredentialValidationError? emailError;
  final CredentialValidationError? passwordError;

  /// Why the provider rejected the attempt, if it did.
  final Failure? failure;

  const SignInState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = SignInStatus.editing,
    this.emailError,
    this.passwordError,
    this.failure,
  });

  bool get isSubmitting => status == SignInStatus.submitting;

  SignInParams get params => SignInParams(email: email, password: password);

  /// Nullable fields are reset unless passed again, so a change in one field
  /// clears its own error while callers re-supply the ones to keep.
  SignInState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    SignInStatus? status,
    CredentialValidationError? emailError,
    CredentialValidationError? passwordError,
    Failure? failure,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      emailError: emailError,
      passwordError: passwordError,
      failure: failure,
    );
  }

  @override
  List<Object?> get props =>
      [email, password, obscurePassword, status, emailError, passwordError, failure];
}
