import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/failures/auth_failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_user_profile_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  AuthCubit(
    this._signInUseCase,
    this._signUpUseCase,
    this._signInWithGoogleUseCase,
    this._signOutUseCase,
    this._getCurrentUserUseCase,
    this._forgotPasswordUseCase,
    this._updateUserProfileUseCase,
  ) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final result = await _getCurrentUserUseCase();
      if (result is DataSuccess) {
        if (result.data != null) {
          emit(AuthAuthenticated(result.data!));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else if (result is DataFailed) {
        emit(AuthError(_messageFrom(result)));
      }
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final result = await _signInUseCase(
        params: SignInParams(email: email, password: password),
      );
      if (result is DataSuccess) {
        emit(AuthAuthenticated(result.data!));
      } else if (result is DataFailed) {
        emit(AuthError(_messageFrom(result)));
      }
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(const AuthLoading());
    try {
      final result = await _signUpUseCase(
        params: SignUpParams(
          email: email,
          password: password,
          displayName: displayName,
        ),
      );
      if (result is DataSuccess) {
        emit(AuthAuthenticated(result.data!));
      } else if (result is DataFailed) {
        emit(AuthError(_messageFrom(result)));
      }
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final result = await _signInWithGoogleUseCase();
      if (result is DataSuccess) {
        emit(AuthAuthenticated(result.data!));
      } else if (result is DataFailed) {
        emit(AuthError(_messageFrom(result)));
      }
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      final result = await _signOutUseCase();
      if (result is DataSuccess) {
        emit(const AuthUnauthenticated());
      } else if (result is DataFailed) {
        emit(AuthError(_messageFrom(result)));
      }
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> forgotPassword({required String email}) async {
    emit(const AuthLoading());
    try {
      final result = await _forgotPasswordUseCase(
        params: ForgotPasswordParams(email: email),
      );
      if (result is DataSuccess) {
        emit(const AuthPasswordResetSent());
      } else if (result is DataFailed) {
        emit(AuthError(_messageFrom(result)));
      }
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> updateUserProfile(UserEntity user) async {
    emit(const AuthLoading());
    try {
      final result = await _updateUserProfileUseCase(
        params: UpdateUserProfileParams(user: user),
      );
      if (result is DataSuccess) {
        emit(AuthAuthenticated(result.data!));
      } else if (result is DataFailed) {
        emit(AuthError(_messageFrom(result)));
      }
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  String _messageFrom(DataState result) {
    final failure = result.error?.error;
    return failure is AuthFailure
        ? failure.message
        : 'Something went wrong. Please try again.';
  }
}
