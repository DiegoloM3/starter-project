part of 'session_cubit.dart';

/// Whether somebody is signed in. Drives the router's redirects.
sealed class SessionState extends Equatable {
  const SessionState();

  /// The signed-in user, or `null`.
  UserEntity? get user => null;

  bool get isAuthenticated => user != null;

  @override
  List<Object?> get props => [];
}

/// The auth provider has not answered yet (app start).
final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

final class SessionAuthenticated extends SessionState {
  @override
  final UserEntity user;

  /// A sign-out or delete-account request is running.
  final bool isBusy;

  /// The last account action that failed, so the screen can say so.
  final Failure? failure;

  const SessionAuthenticated(this.user, {this.isBusy = false, this.failure});

  SessionAuthenticated copyWith({bool? isBusy, Failure? failure}) {
    return SessionAuthenticated(
      user,
      isBusy: isBusy ?? this.isBusy,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [user, isBusy, failure];
}
