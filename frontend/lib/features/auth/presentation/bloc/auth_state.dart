import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

/// Sealed class containing all states for [AuthBloc].
///
/// 6 states per design D1. Dart 3 sealed gives exhaustive switch checking.
sealed class AuthState extends Equatable {
  const AuthState();
}

/// BLoC has just been created — no auth action taken yet.
final class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

/// An async auth operation is in progress.
/// Emitted SYNCHRONOUSLY before every async call (design D11 — optimistic UI).
final class AuthAuthenticating extends AuthState {
  const AuthAuthenticating();

  @override
  List<Object?> get props => [];
}

/// User is signed in anonymously.
final class AuthAnonymous extends AuthState {
  final AuthUserEntity user;
  const AuthAnonymous(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is signed in with a real credential (email/Google).
final class AuthAuthenticated extends AuthState {
  final AuthUserEntity user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User has just signed out. Transient — bloc immediately dispatches
/// SignInAnonymously to converge back to [AuthAnonymous] (design D1).
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  List<Object?> get props => [];
}

/// An auth operation failed. Holds the error and the last valid state
/// so [ErrorDismissedEvent] can revert cleanly.
final class AuthError extends AuthState {
  final AppException error;

  /// The state that was active before this error — used for revert on dismiss.
  final AuthState previousState;

  const AuthError(this.error, {required this.previousState});

  @override
  List<Object?> get props => [error, previousState];
}
