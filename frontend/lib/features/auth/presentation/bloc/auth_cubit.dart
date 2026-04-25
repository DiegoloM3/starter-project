import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/session/firebase_auth_session.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

/// Drives the login + register screen.
///
/// Translates `FirebaseAuthException` codes into copy the UI can show
/// directly, so the page doesn't have to know about Firebase error codes.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._session) : super(const AuthState.idle());

  final FirebaseAuthSession _session;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.submitting());
    try {
      await _session.signIn(email: email, password: password);
      emit(const AuthState.success());
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthState.failure(_signInMessage(e)));
    } catch (_) {
      emit(const AuthState.failure('Could not sign in. Try again.'));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(const AuthState.submitting());
    try {
      await _session.signUp(email: email, password: password, name: name);
      emit(const AuthState.success());
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthState.failure(_signUpMessage(e)));
    } catch (_) {
      emit(const AuthState.failure('Could not create the account. Try again.'));
    }
  }

  void resetError() {
    if (state.status == AuthStatus.failure) {
      emit(const AuthState.idle());
    }
  }

  String _signInMessage(fb.FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'That email address looks invalid.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' || 'invalid-credential' || 'wrong-password' =>
        'Email or password is incorrect.',
      'too-many-requests' => 'Too many attempts. Try again in a minute.',
      'network-request-failed' => 'No internet connection.',
      _ => e.message ?? 'Could not sign in.',
    };
  }

  String _signUpMessage(fb.FirebaseAuthException e) {
    return switch (e.code) {
      'email-already-in-use' => 'An account with that email already exists.',
      'invalid-email' => 'That email address looks invalid.',
      'weak-password' => 'Password is too weak — use at least 6 characters.',
      'operation-not-allowed' =>
        'Email/password sign-up is disabled in this Firebase project.',
      'network-request-failed' => 'No internet connection.',
      _ => e.message ?? 'Could not create the account.',
    };
  }
}
