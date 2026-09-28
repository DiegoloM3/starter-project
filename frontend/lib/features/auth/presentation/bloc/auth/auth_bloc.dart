import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/login_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/logout_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
/// UI state machine for authentication; delegates work to auth use cases.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ClearAuthError>(_onClearAuthError);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCurrentUserUseCase();
    if (result is DataSuccess && result.data != null && !result.data!.isAnonymous) {
      emit(Authenticated(result.data!));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.email.trim().isEmpty) {
      emit(const AuthError('Email cannot be empty.'));
      return;
    }
    if (event.password.trim().isEmpty) {
      emit(const AuthError('Password cannot be empty.'));
      return;
    }

    emit(const AuthLoading());

    final result = await _loginUseCase(
      params: LoginParams(
        email: event.email.trim(),
        password: event.password,
      ),
    );

    if (result is DataSuccess && result.data != null) {
      emit(Authenticated(result.data!));
    } else {
      emit(AuthError('Failed to SigIn'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.email.trim().isEmpty) {
      emit(const AuthError('Email cannot be empty.'));
      return;
    }
    if (event.password.length < 6) {
      emit(const AuthError('Password must be at least 6 characters.'));
      return;
    }

    emit(const AuthLoading());

    final result = await _registerUseCase(
      params: RegisterParams(
        email: event.email.trim(),
        password: event.password,
        displayName: event.displayName?.trim(),
      ),
    );

    if (result is DataSuccess && result.data != null) {
      emit(Authenticated(result.data!));
    } else {
      emit(AuthError('Failed to register.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _logoutUseCase();
    emit(const Unauthenticated());
  }

  void _onClearAuthError(
    ClearAuthError event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthError) {
      emit(const Unauthenticated());
    }
  }
}
