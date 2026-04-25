import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_anonymous.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignInAnonymousUseCase _signInAnonymousUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthCubit(
    this._signInUseCase,
    this._signUpUseCase,
    this._signInAnonymousUseCase,
    this._signOutUseCase,
    this._getCurrentUserUseCase,
  ) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _signInUseCase(
        params: SignInParams(email: email, password: password),
      );
      emit(AuthSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signUpUseCase(
        params: SignUpParams(
          email: email,
          password: password,
          displayName: displayName,
        ),
      );
      emit(AuthSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInAnonymous() async {
    emit(const AuthLoading());
    try {
      final user = await _signInAnonymousUseCase();
      emit(AuthSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await _signOutUseCase();
      emit(const AuthUnauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
