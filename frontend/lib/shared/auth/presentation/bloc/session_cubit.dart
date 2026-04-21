import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/auth_credentials.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/watch_auth_state.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/session_state.dart';

class SessionDeps {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final WatchAuthStateUseCase watchAuthState;

  const SessionDeps({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.watchAuthState,
  });
}

class SessionCubit extends Cubit<SessionState> {
  final SessionDeps _deps;
  StreamSubscription<AuthUserEntity?>? _subscription;

  SessionCubit(this._deps) : super(const SessionInitial()) {
    _subscription = _deps.watchAuthState().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(AuthUserEntity? user) {
    if (user == null) {
      emit(const SessionUnauthenticated());
    } else {
      emit(SessionAuthenticated(user));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(const SessionAuthenticating());
    try {
      await _deps.signIn(
          params: AuthCredentials(email: email, password: password));
    } on AuthException catch (e) {
      emit(SessionFailure(e.message));
    }
  }

  Future<void> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    emit(const SessionAuthenticating());
    try {
      final user = await _deps.signUp(
          params: AuthCredentials(
        email: email,
        password: password,
        displayName: displayName,
      ));
      emit(SessionAuthenticated(user));
    } on AuthException catch (e) {
      emit(SessionFailure(e.message));
    }
  }

  Future<void> signOut() => _deps.signOut();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
