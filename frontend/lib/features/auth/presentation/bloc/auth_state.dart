enum AuthStatus { idle, submitting, success, failure }

class AuthState {
  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
  });

  const AuthState.idle() : this();
  const AuthState.submitting() : this(status: AuthStatus.submitting);
  const AuthState.success() : this(status: AuthStatus.success);
  const AuthState.failure(String message)
      : this(status: AuthStatus.failure, errorMessage: message);

  final AuthStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == AuthStatus.submitting;
}
