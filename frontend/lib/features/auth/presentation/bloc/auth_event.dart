part of 'auth_bloc.dart';

/// Events that trigger state changes in the AuthBloc.
///
/// Each event represents a user action or system event that may change
/// the authentication state.
sealed class AuthEvent {
  const AuthEvent();
}

/// User initiated sign-in with email and password.
final class SignInWithEmailRequested extends AuthEvent {
  const SignInWithEmailRequested({required this.email, required this.password});

  final String email;
  final String password;
}

/// User initiated sign-up with email, password, and display name.
final class SignUpWithEmailRequested extends AuthEvent {
  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;
}

/// User initiated Google sign-in.
final class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

/// User initiated sign-out.
final class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Welcome screen consumed the explicit sign-out navigation state.
final class SignOutRedirectAcknowledged extends AuthEvent {
  const SignOutRedirectAcknowledged();
}

/// Internal event — not part of the public API.
/// Added by the stream subscription in [AuthBloc] whenever Firebase
/// auth state changes.
final class _AuthStatusChanged extends AuthEvent {
  const _AuthStatusChanged(this.status);
  final AuthStatus status;
}
