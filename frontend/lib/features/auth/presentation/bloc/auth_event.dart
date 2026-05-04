import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';

sealed class AuthEvent {
  const AuthEvent();
}

/// Starts watching the Firebase auth state stream.
/// Dispatched once at app root in MyApp.
final class WatchAuthStateEvent extends AuthEvent {}

/// Signs in anonymously. Dispatched automatically when the auth stream
/// emits null (no current user) — never dispatched directly by UI.
final class SignInAnonymouslyEvent extends AuthEvent {}

/// Signs in with email and password.
final class SignInWithEmailEvent extends AuthEvent {
  final SignInParams params;
  const SignInWithEmailEvent(this.params);
}

/// Creates a new account with email, password, and display name.
final class SignUpWithEmailEvent extends AuthEvent {
  final SignUpParams params;
  const SignUpWithEmailEvent(this.params);
}

/// Launches the Google Sign-In flow.
final class SignInWithGoogleEvent extends AuthEvent {}

/// Signs out the current user and triggers re-anonymous sign-in.
final class SignOutEvent extends AuthEvent {}

/// Sends a password-reset email.
final class SendPasswordResetEvent extends AuthEvent {
  final String email;
  const SendPasswordResetEvent(this.email);
}

/// Acknowledges and dismisses the current [AuthError], reverting state.
final class ErrorDismissedEvent extends AuthEvent {}

/// Links the current anonymous user to an email/password credential.
/// Dispatched by SignupPage when the current user is anonymous.
final class LinkAnonymousWithEmailEvent extends AuthEvent {
  final SignUpParams params;
  const LinkAnonymousWithEmailEvent(this.params);
}

/// Links the current anonymous user to a Google credential.
/// Dispatched by SignupPage or LoginPage when the current user is anonymous.
final class LinkAnonymousWithGoogleEvent extends AuthEvent {
  const LinkAnonymousWithGoogleEvent();
}
