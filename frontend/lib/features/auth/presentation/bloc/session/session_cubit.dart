import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';

part 'session_state.dart';

/// Mirrors the identity provider's session for the whole app.
///
/// Lives above the router: every screen can read who is signed in, and the
/// router redirects when the state flips. Sign-in and sign-up forms have
/// their own cubits; this one only reflects the outcome and handles the one
/// account-wide action, signing out.
class SessionCubit extends Cubit<SessionState> {
  final WatchAuthStateUseCase _watchAuthState;
  final SignOutUseCase _signOut;
  StreamSubscription<UserEntity?>? _subscription;

  SessionCubit(this._watchAuthState, this._signOut)
      : super(const SessionUnknown()) {
    _subscription = _watchAuthState(const NoParams()).listen(_onUserChanged);
  }

  void _onUserChanged(UserEntity? user) {
    emit(user == null ? const SessionUnauthenticated() : SessionAuthenticated(user));
  }

  Future<void> signOut() => _runAccountAction(() => _signOut(const NoParams()));

  Future<void> _runAccountAction(
    Future<DataState<void>> Function() action,
  ) async {
    final current = state;
    if (current is! SessionAuthenticated || current.isBusy) return;

    emit(current.copyWith(isBusy: true));
    final result = await action();

    // On success the auth stream already moved the session to signed out.
    if (result is DataFailed<void> && state is SessionAuthenticated) {
      emit(current.copyWith(isBusy: false, failure: result.failure));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
