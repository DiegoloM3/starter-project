import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_auth_state_changes.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/forgot_password.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetAuthStateChangesUseCase _getAuthStateChangesUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;

  StreamSubscription<UserEntity?>? _authStateSubscription;
  bool _isChangingPassword = false;
  bool _isAuthenticating = false;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required GetAuthStateChangesUseCase getAuthStateChangesUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getAuthStateChangesUseCase = getAuthStateChangesUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);

    // Start listening to auth state changes
    _startAuthStateListener();
  }

  void _startAuthStateListener() {
    _authStateSubscription?.cancel();
    _authStateSubscription = _getAuthStateChangesUseCase().listen(
      (user) {
        // Ignore auth state changes during authentication or password change
        if (_isChangingPassword || _isAuthenticating) return;

        if (user != null) {
          add(const AuthStateChanged(isAuthenticated: true));
        } else {
          add(const AuthStateChanged(isAuthenticated: false));
        }
      },
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _getCurrentUserUseCase();

      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      // If there's an error checking auth status, treat as unauthenticated
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _isAuthenticating = true;

    try {
      final dataState = await _signInUseCase(
        params: SignInParams(
          email: event.email,
          password: event.password,
        ),
      );

      if (dataState.data != null) {
        emit(Authenticated(dataState.data!));
      } else {
        final errorMessage = _cleanErrorMessage(
          dataState.exception?.toString() ?? dataState.error?.toString(),
          'Sign in failed',
        );
        final failure = _mapErrorToFailure(errorMessage);
        emit(AuthError(
          message: errorMessage,
          failure: failure,
        ));
      }
    } catch (e) {
      final errorMessage = _cleanErrorMessage(e.toString(), 'Sign in failed');
      final failure = _mapErrorToFailure(errorMessage);
      emit(AuthError(
        message: errorMessage,
        failure: failure,
      ));
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _isAuthenticating = true;

    try {
      final dataState = await _signUpUseCase(
        params: SignUpParams(
          email: event.email,
          password: event.password,
          displayName: event.displayName ?? '',
        ),
      );

      if (dataState.data != null) {
        emit(Authenticated(dataState.data!));
      } else {
        final errorMessage = _cleanErrorMessage(
          dataState.exception?.toString() ?? dataState.error?.toString(),
          'Sign up failed',
        );
        final failure = _mapErrorToFailure(errorMessage);
        emit(AuthError(
          message: errorMessage,
          failure: failure,
        ));
      }
    } catch (e) {
      final errorMessage = _cleanErrorMessage(e.toString(), 'Sign up failed');
      final failure = _mapErrorToFailure(errorMessage);
      emit(AuthError(
        message: errorMessage,
        failure: failure,
      ));
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _signOutUseCase();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(
        message: e.toString(),
      ));
    }
  }

  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.isAuthenticated) {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(Authenticated(user));
      }
    } else {
      // Don't overwrite AuthError state - let the UI display the error
      if (state is! AuthError) {
        emit(const Unauthenticated());
      }
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = await _getCurrentUserUseCase();
    if (currentUser == null) {
      emit(const PasswordChangeError(message: 'No authenticated user'));
      return;
    }

    emit(PasswordChanging(currentUser));

    // Pause auth state listener during password change
    _isChangingPassword = true;

    try {
      final dataState = await _changePasswordUseCase(
        params: ChangePasswordParams(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
        ),
      );

      if (dataState.exception == null) {
        // Get fresh user data after password change
        final updatedUser = await _getCurrentUserUseCase();
        emit(PasswordChanged(updatedUser ?? currentUser));
        // Return to authenticated state after brief success indication
        emit(Authenticated(updatedUser ?? currentUser));
      } else {
        final errorMessage = _cleanErrorMessage(
          dataState.exception?.toString(),
          'Password change failed',
        );

        emit(PasswordChangeError(
          message: errorMessage,
          user: currentUser,
        ));
        // Return to authenticated state so UI can recover
        emit(Authenticated(currentUser));
      }
    } finally {
      // Resume auth state listener
      _isChangingPassword = false;
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const ForgotPasswordLoading());

    final dataState = await _forgotPasswordUseCase(
      params: ForgotPasswordParams(email: event.email),
    );

    if (dataState.exception == null) {
      emit(const ForgotPasswordEmailSent());
    } else {
      final errorMessage = _cleanErrorMessage(
        dataState.exception?.toString(),
        'Failed to send reset email',
      );
      emit(ForgotPasswordError(message: errorMessage));
    }
  }

  /// Cleans error message by removing "Exception: " prefix
  String _cleanErrorMessage(String? error, String defaultMessage) {
    if (error == null || error.isEmpty) return defaultMessage;

    // Remove "Exception: " prefix if present
    if (error.startsWith('Exception: ')) {
      return error.substring(11);
    }
    return error;
  }

  AuthFailure _mapErrorToFailure(String? error) {
    if (error == null) return AuthFailure.unknown;

    final lowerError = error.toLowerCase();

    if (lowerError.contains('invalid-email') ||
        lowerError.contains('invalid email')) {
      return AuthFailure.invalidEmail;
    }
    if (lowerError.contains('wrong-password') ||
        lowerError.contains('wrong password')) {
      return AuthFailure.wrongPassword;
    }
    if (lowerError.contains('user-not-found') ||
        lowerError.contains('user not found')) {
      return AuthFailure.userNotFound;
    }
    if (lowerError.contains('email-already-in-use') ||
        lowerError.contains('email already')) {
      return AuthFailure.emailAlreadyInUse;
    }
    if (lowerError.contains('weak-password') ||
        lowerError.contains('weak password')) {
      return AuthFailure.weakPassword;
    }
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return AuthFailure.networkError;
    }

    return AuthFailure.unknown;
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
