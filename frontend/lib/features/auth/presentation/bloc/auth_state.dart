part of 'auth_bloc.dart';

/// States representing the authentication UI.
///
/// Pattern: Each state corresponds to a distinct UI representation.
/// Errors are represented by the [failure.message] field, which is an l10n key.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication operation.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An authentication operation is in progress (loading).
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
///
/// Contains the authenticated user's data.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated (no session / guest browsing).
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// User explicitly signed out.
///
/// Distinct from [AuthUnauthenticated] so the router can redirect to the
/// welcome screen only on an explicit sign-out, while still allowing guest
/// browsing when the user was never signed in.
final class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

/// An authentication error occurred.
///
/// The [failure.message] field is an l10n key (e.g. 'auth.userNotFound').
/// The presentation layer is responsible for translating this key to a user-friendly message.
final class AuthError extends AuthState {
  const AuthError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
