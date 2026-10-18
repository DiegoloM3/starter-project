import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../../../shared/users/domain/entities/user.dart';
import '../../../domain/usecases/sign_out.dart';
import '../../../domain/usecases/watch_current_user.dart';
import 'auth_state.dart';

/// Session of the whole app: it follows the signed in user.
class AuthCubit extends Cubit<AuthState> {
  final SignOutUseCase _signOutUseCase;
  late final StreamSubscription<UserEntity?> _currentUserSubscription;

  AuthCubit(WatchCurrentUserUseCase watchCurrentUserUseCase, this._signOutUseCase) : super(const AuthUnknown()) {
    _currentUserSubscription = watchCurrentUserUseCase(const NoParams()).listen(_onCurrentUserChanged);
  }

  Future<void> signOut() => _signOutUseCase(const NoParams());

  void _onCurrentUserChanged(UserEntity? user) {
    emit(user == null ? const AuthUnauthenticated() : AuthAuthenticated(user));
  }

  @override
  Future<void> close() async {
    await _currentUserSubscription.cancel();
    return super.close();
  }
}
