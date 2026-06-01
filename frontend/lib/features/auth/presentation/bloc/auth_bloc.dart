import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/auth/domain/use_cases/check_auth_use_case.dart';
import 'package:tortutip/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:tortutip/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_event.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthUseCase _checkAuth;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;

  AuthBloc(
    this._checkAuth,
    this._signInWithGoogle,
    this._signOut,
  ) : super(const AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<SignInWithGoogleEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<RefreshUserEvent>(_onRefreshUser);
  }

  Future<void> _onCheckAuth(
      CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _checkAuth(const NoParams());
    if (result.isSuccess) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(const AuthInitial());
    }
  }

  Future<void> _onSignIn(
      SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle(const NoParams());
    if (result.isSuccess) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(_mapSignInError(result.error!)));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    final result = await _signOut(const NoParams());
    if (result.isSuccess) {
      emit(const AuthInitial());
    } else {
      emit(AuthError(_mapSignOutError(result.error!)));
    }
  }

  Future<void> _onRefreshUser(
      RefreshUserEvent event, Emitter<AuthState> emit) async {
    final result = await _checkAuth(const NoParams());
    if (result.isSuccess) {
      emit(AuthAuthenticated(result.data!));
    }
  }

  String _mapSignInError(Exception error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('cancelled') || msg.contains('cancel')) {
      return '';
    }
    // Error 10 = SHA-1 no registrado en Firebase Console
    if (msg.contains('developer_error') || msg.contains('10:') || msg.contains('error_code=10')) {
      return 'Configuración de Google incorrecta. Contacta al soporte.';
    }
    // ignore: avoid_print
    assert(() { print('[AuthBloc] signIn error: $error'); return true; }());
    return 'No se pudo iniciar sesión. Inténtalo de nuevo';
  }

  String _mapSignOutError(Exception error) {
    return 'No se pudo cerrar la sesión. Inténtalo de nuevo';
  }
}
