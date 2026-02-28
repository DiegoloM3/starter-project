import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthCubit(
    this._getCurrentUserUseCase,
    this._signInUseCase,
    this._signOutUseCase,
  ) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    final user = await _getCurrentUserUseCase();
    _emitUser(user);
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    try {
      await _signInUseCase(params: SignInParams(email, password));
      final user = await _getCurrentUserUseCase();
      _emitUser(user);
    } catch (_) {
      emit(const AuthFailure('Failed to sign in'));
    }
  }

  Future<void> signOut() async {
    await _signOutUseCase();
    emit(const AuthUnauthenticated());
  }

  void _emitUser(AuthUser? user) {
    if (user == null) {
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(user));
    }
  }
}

