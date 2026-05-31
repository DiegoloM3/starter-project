import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/errors/failure.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/domain.dart';
part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC managing authentication state and business logic.
///
/// Subscribes to the Firebase auth stream in the constructor following the
/// pattern recommended by the bloc team (firebase_login sample). Each stream
/// emission is converted into an internal [_AuthStatusChanged] event so the
/// sequential event queue is never blocked.
///
/// Responsibilities:
/// 1. Handles authentication events from the presentation layer
/// 2. Calls appropriate use cases to perform authentication operations
/// 3. Emits states reflecting the result of each operation
/// 4. Converts [DataState] results from use cases into [AuthState] for UI
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Constructs an [AuthBloc] with all required authentication use cases.
  AuthBloc(
    this._signInWithEmail,
    this._signUpWithEmail,
    this._signInWithGoogle,
    this._signOut,
    this._getAuthStream,
  ) : super(const AuthInitial()) {
    on<_AuthStatusChanged>(_onAuthStatusChanged);
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignUpWithEmailRequested>(_onSignUpWithEmail);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignOutRequested>(_onSignOut);
    on<SignOutRedirectAcknowledged>(_onSignOutRedirectAcknowledged);

    // Subscribe once for the lifetime of the bloc. Each Firebase auth change
    // adds an internal event — this never blocks the sequential event queue.
    _authStatusSubscription = _getAuthStream().listen(
      (status) => add(_AuthStatusChanged(status)),
    );
  }

  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final GetAuthStream _getAuthStream;
  late final StreamSubscription<AuthStatus> _authStatusSubscription;

  /// Translates Firebase auth stream events into BLoC states.
  void _onAuthStatusChanged(_AuthStatusChanged event, Emitter<AuthState> emit) {
    switch (event.status) {
      case Authenticated(:final user):
        emit(AuthAuthenticated(user: user));
      case Unauthenticated():
        emit(const AuthUnauthenticated());
      case AuthUnknown():
        emit(const AuthInitial());
    }
  }

  @override
  Future<void> close() {
    _authStatusSubscription.cancel();
    return super.close();
  }

  /// Handles [SignInWithEmailRequested] event.
  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final dataState = await _signInWithEmail(
      params: (email: event.email, password: event.password),
    );

    switch (dataState) {
      case DataSuccess<dynamic>(:final data):
        emit(AuthAuthenticated(user: data));
      case DataFailed<dynamic>(:final failure):
        emit(AuthError(failure: failure));
    }
  }

  /// Handles [SignUpWithEmailRequested] event.
  Future<void> _onSignUpWithEmail(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final dataState = await _signUpWithEmail(
      params: (
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );

    switch (dataState) {
      case DataSuccess<dynamic>(:final data):
        emit(AuthAuthenticated(user: data));
      case DataFailed<dynamic>(:final failure):
        emit(AuthError(failure: failure));
    }
  }

  /// Handles [SignInWithGoogleRequested] event.
  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final dataState = await _signInWithGoogle();

    switch (dataState) {
      case DataSuccess<dynamic>(:final data):
        emit(AuthAuthenticated(user: data));
      case DataFailed<dynamic>(:final failure):
        emit(AuthError(failure: failure));
    }
  }

  /// Handles [SignOutRequested] event.
  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final dataState = await _signOut();

    switch (dataState) {
      case DataSuccess<dynamic>():
        emit(const AuthSignedOut());
      case DataFailed<dynamic>(:final failure):
        emit(AuthError(failure: failure));
    }
  }

  void _onSignOutRedirectAcknowledged(
    SignOutRedirectAcknowledged event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthSignedOut) {
      emit(const AuthUnauthenticated());
    }
  }
}
