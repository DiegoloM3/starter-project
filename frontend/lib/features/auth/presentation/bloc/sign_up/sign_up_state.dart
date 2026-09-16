part of 'sign_up_cubit.dart';

enum SignUpStatus { editing, submitting, success, failure }

class SignUpState extends Equatable {
  final String displayName;
  final String email;
  final String password;
  final bool obscurePassword;
  final SignUpStatus status;
  final CredentialValidationError? displayNameError;
  final CredentialValidationError? emailError;
  final CredentialValidationError? passwordError;
  final Failure? failure;

  const SignUpState({
    this.displayName = '',
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = SignUpStatus.editing,
    this.displayNameError,
    this.emailError,
    this.passwordError,
    this.failure,
  });

  bool get isSubmitting => status == SignUpStatus.submitting;

  /// Guidance for the strength meter; `null` until the user starts typing.
  PasswordStrength? get passwordStrength =>
      password.isEmpty ? null : PasswordStrength.of(password);

  SignUpParams get params => SignUpParams(
        displayName: displayName,
        email: email,
        password: password,
      );

  /// Nullable fields are reset unless passed again, so a change in one field
  /// clears its own error while callers re-supply the ones to keep.
  SignUpState copyWith({
    String? displayName,
    String? email,
    String? password,
    bool? obscurePassword,
    SignUpStatus? status,
    CredentialValidationError? displayNameError,
    CredentialValidationError? emailError,
    CredentialValidationError? passwordError,
    Failure? failure,
  }) {
    return SignUpState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      displayNameError: displayNameError,
      emailError: emailError,
      passwordError: passwordError,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
        displayName,
        email,
        password,
        obscurePassword,
        status,
        displayNameError,
        emailError,
        passwordError,
        failure,
      ];
}
