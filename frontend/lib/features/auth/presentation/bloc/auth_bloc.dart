import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/link_anonymous_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/link_anonymous_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/send_password_reset.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_anonymously.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Global auth BLoC — observer of [FirebaseAuth.authStateChanges].
///
/// Bootstrap responsibility lives in `main()`, not here. By the time the
/// bloc receives [WatchAuthStateEvent] the auth stream already has a stable
/// initial value. The bloc only translates stream emissions to bloc states;
/// it never calls `signInAnonymously` proactively to avoid creating a new
/// anonymous user on each cold start on Android.
///
/// Sign-in/sign-up/link/sign-out events do their own one-shot work and let
/// the auth stream propagate the resulting state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final WatchAuthStateUseCase _watchAuthState;
  final SignInAnonymouslyUseCase _signInAnonymously;
  final SignInWithEmailUseCase _signInWithEmail;
  final SignUpWithEmailUseCase _signUpWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;
  final SendPasswordResetUseCase _sendPasswordReset;
  final LinkAnonymousWithEmailUseCase _linkAnonymousWithEmail;
  final LinkAnonymousWithGoogleUseCase _linkAnonymousWithGoogle;

  StreamSubscription<dynamic>? _authSubscription;

  /// Becomes true after the first [WatchAuthStateEvent] handler subscribes.
  /// Subsequent dispatches (caused by widget rebuilds re-issuing the event)
  /// become no-ops; otherwise each duplicate event spawns its own stream
  /// subscription.
  bool _watchStarted = false;

  AuthBloc(
    this._watchAuthState,
    this._signInAnonymously,
    this._signInWithEmail,
    this._signUpWithEmail,
    this._signInWithGoogle,
    this._signOut,
    this._sendPasswordReset,
    this._linkAnonymousWithEmail,
    this._linkAnonymousWithGoogle,
  ) : super(const AuthInitial()) {
    on<WatchAuthStateEvent>(_onWatchAuthState);
    on<SignInAnonymouslyEvent>(_onSignInAnonymously);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<SendPasswordResetEvent>(_onSendPasswordReset);
    on<ErrorDismissedEvent>(_onErrorDismissed);
    on<LinkAnonymousWithEmailEvent>(_onLinkAnonymousWithEmail);
    on<LinkAnonymousWithGoogleEvent>(_onLinkAnonymousWithGoogle);
  }

  // -------------------------------------------------------------------
  // Handlers
  // -------------------------------------------------------------------

  Future<void> _onWatchAuthState(
    WatchAuthStateEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_watchStarted) return;
    _watchStarted = true;

    await emit.onEach<dynamic>(
      _watchAuthState.call(params: const NoParams()),
      onData: (user) {
        if (user == null) {
          emit(const AuthUnauthenticated());
        } else if (user.isAnonymous) {
          emit(AuthAnonymous(user));
        } else {
          emit(AuthAuthenticated(user));
        }
      },
      onError: (error, stackTrace) {
        emit(AuthError(
          error is Exception
              ? error as dynamic
              : Exception(error.toString()),
          previousState: state,
        ));
      },
    );
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymouslyEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(const AuthAuthenticating());

    final result = await _signInAnonymously.call(params: const NoParams());
    if (result is DataFailed) {
      emit(AuthError(result.error!, previousState: prevState));
    }
    // On success the stream will emit the new user and the watch handler
    // will translate it to AuthAnonymous; no explicit emit needed here.
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(const AuthAuthenticating());

    final result = await _signInWithEmail.call(params: event.params);
    if (result is DataFailed) {
      emit(AuthError(result.error!, previousState: prevState));
    }
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(const AuthAuthenticating());

    final result = await _signUpWithEmail.call(params: event.params);
    if (result is DataFailed) {
      emit(AuthError(result.error!, previousState: prevState));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(const AuthAuthenticating());

    final result = await _signInWithGoogle.call(params: const NoParams());
    if (result is DataFailed) {
      final error = result.error!;
      if (error is AuthException && error.code == 'popup-closed-by-user') {
        // Cancellation — silently revert to previous state.
        emit(prevState);
      } else {
        emit(AuthError(error, previousState: prevState));
      }
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(const AuthAuthenticating());

    final result = await _signOut.call(params: const NoParams());
    if (result is DataFailed) {
      emit(AuthError(result.error!, previousState: prevState));
      return;
    }
    // After explicit sign-out, drop straight back into anonymous mode so
    // the user can keep browsing the feed without bouncing through /login
    // (Symmetry "anonymous-first" UX, design D1 / SD3).
    add(SignInAnonymouslyEvent());
  }

  Future<void> _onSendPasswordReset(
    SendPasswordResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _sendPasswordReset.call(params: event.email);
  }

  void _onErrorDismissed(
    ErrorDismissedEvent event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is AuthError) {
      emit(currentState.previousState);
    }
  }

  Future<void> _onLinkAnonymousWithEmail(
    LinkAnonymousWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(const AuthAuthenticating());

    final result =
        await _linkAnonymousWithEmail.call(params: event.params);
    if (result is DataFailed<AuthUserEntity>) {
      emit(AuthError(result.error!, previousState: prevState));
    }
    // On success the auth stream fires and the watch handler emits
    // AuthAuthenticated — no explicit emit needed here.
  }

  Future<void> _onLinkAnonymousWithGoogle(
    LinkAnonymousWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(const AuthAuthenticating());

    final result =
        await _linkAnonymousWithGoogle.call(params: const NoParams());
    if (result is DataFailed<AuthUserEntity>) {
      final error = result.error!;
      if (error is AuthException && error.code == 'cancelled') {
        emit(prevState);
      } else {
        emit(AuthError(error, previousState: prevState));
      }
    }
  }

  // -------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
