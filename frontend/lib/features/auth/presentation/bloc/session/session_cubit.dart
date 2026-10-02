import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_session.dart';

import 'session_state.dart';

/// Who is using the app. The whole app follows it: it shows the welcome screen when nobody is signed in.
class SessionCubit extends Cubit<SessionState> {
  final WatchSessionUseCase _watchSessionUseCase;
  final SignOutUseCase _signOutUseCase;

  StreamSubscription<UserEntity?>? _sessionSubscription;

  SessionCubit(this._watchSessionUseCase, this._signOutUseCase) : super(const SessionUnknown());

  /// Starts following the session and completes once the one kept on the phone is known,
  /// so the app can open directly on the right screen.
  Future<void> watchSession() {
    final firstSession = Completer<void>();
    _sessionSubscription = _watchSessionUseCase().listen((user) {
      emit(user == null ? const SessionSignedOut() : SessionSignedIn(user));
      if (!firstSession.isCompleted) firstSession.complete();
    });
    return firstSession.future;
  }

  /// The session stream reports the change, so the app goes back to the welcome screen by itself.
  Future<void> signOut() => _signOutUseCase();

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    return super.close();
  }
}
