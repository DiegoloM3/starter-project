import 'package:equatable/equatable.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/auth_failures.dart';

enum SessionStatus {
  /// Before the app has looked up whether anybody is signed in.
  unknown,
  signedOut,
  signedIn,
  busy,
  failure,
}

/// Who is using the app right now.
///
/// [SessionStatus.signedOut] is an ordinary, fully working state: reading the
/// app never requires an account (see `docs/DECISIONS.md` decision #31).
class SessionState extends Equatable {
  final SessionStatus status;
  final AppUserEntity? user;
  final List<CredentialsValidationError> validationErrors;
  final Object? error;

  const SessionState({
    this.status = SessionStatus.unknown,
    this.user,
    this.validationErrors = const [],
    this.error,
  });

  bool get isSignedIn => user != null;

  bool get isBusy => status == SessionStatus.busy;

  SessionState copyWith({
    SessionStatus? status,
    AppUserEntity? user,
    bool clearUser = false,
    List<CredentialsValidationError>? validationErrors,
    Object? error,
    bool clearError = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      validationErrors: validationErrors ?? this.validationErrors,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, user, validationErrors, error];
}
