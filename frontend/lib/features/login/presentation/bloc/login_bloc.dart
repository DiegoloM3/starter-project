import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:news_app_clean_architecture/core/errors/auth_exception.dart';
import 'package:news_app_clean_architecture/core/extensions/string_extensions.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/create_user_params.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/sign_in_with_email_and_password_params.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/create_user.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/login_stream.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:news_app_clean_architecture/features/login/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_field_error.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/register_field_error.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginStreamUseCase _loginStreamUseCase;
  final CreateUserUseCase _createUserUseCase;
  final SignInWithEmailAndPasswordUseCase _signInWithEmailAndPasswordUseCase;
  final SignOutUseCase _signOutUseCase;

  LoginBloc(
    this._loginStreamUseCase,
    this._createUserUseCase,
    this._signInWithEmailAndPasswordUseCase,
    this._signOutUseCase,
  ) : super(LoginInitial()) {
    on<StartWatchingUser>(_onWatchUserSubscription);
    on<CreateUserRequested>(_onCreateUserRequested);
    on<SignInWithEmailAndPasswordRequested>(
        _onSignInWithEmailAndPasswordRequested);
    on<SignOutRequested>(_onSignOutRequested);

    add(StartWatchingUser());
  }

  Future<void> _onWatchUserSubscription(
    StartWatchingUser event,
    Emitter<LoginState> emit,
  ) async {
    await emit.forEach(_loginStreamUseCase.call(NoParams()), onData: (user) {
      if (user != null && state is! LoggedIn) {
        return LoggedIn(user: user);
      } else {
        return const NotLoggedIn();
      }
    });
  }

  Future<void> _onSignInWithEmailAndPasswordRequested(
    SignInWithEmailAndPasswordRequested event,
    Emitter<LoginState> emit,
  ) async {
    final fieldsErrors = [
      if (!event.email.isValidEmail) LoginFieldError.emailNotValid,
      if (event.email.isEmpty) LoginFieldError.emailRequired,
      if (!event.password.isStrongPassword) LoginFieldError.passwordNotValid,
      if (event.password.isEmpty) LoginFieldError.passwordRequired,
    ];

    if (fieldsErrors.isNotEmpty) {
      emit(
        NotLoggedIn(
          loginErrors: fieldsErrors,
        ),
      );
    } else {
      emit(const LoginLoading());
      final dataState = await _signInWithEmailAndPasswordUseCase(
        SignInWithEmailAndPasswordParams(
          email: event.email,
          password: event.password,
        ),
      );

      if (dataState is DataSuccess && dataState.data != null) {
        emit(
          LoggedIn(
            user: dataState.data!,
          ),
        );
      } else if (dataState is DataFailed) {
        _emitError(dataState, emit);
      }
    }
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<LoginState> emit) async {
    final dataState = await _signOutUseCase(NoParams());

    if (dataState is DataSuccess) {
      emit(const NotLoggedIn());
    } else if (dataState is DataFailed) {
      _emitError(dataState, emit);
    }
  }

  void _emitError(DataFailed failure, Emitter<LoginState> emit) async {
    if (failure.error != null && failure.error is EmailAlreadyInUseException) {
      emit(
        const NotLoggedIn(
          registerErrors: [RegisterFieldError.emailAlreadyRegistered],
        ),
      );
    } else if (failure.error != null &&
        failure.error is InvalidCredentialException) {
      emit(
        const NotLoggedIn(
          loginErrors: [LoginFieldError.invalidCredentials],
        ),
      );
    } else {
      emit(
        LoginError(
          message: failure.error?.toString() ?? 'Unknown Error',
        ),
      );
    }
  }

  Future<void> _onCreateUserRequested(
      CreateUserRequested event, Emitter<LoginState> emit) async {
    final fieldsErrors = [
      if (event.user.name.isEmpty) RegisterFieldError.nameRequired,
      if (!event.user.email.isValidEmail) RegisterFieldError.emailNotValid,
      if (event.user.email.isEmpty) RegisterFieldError.emailRequired,
      if (!event.password.isStrongPassword) RegisterFieldError.passwordNotValid,
      if (event.password.isEmpty) RegisterFieldError.passwordRequired,
    ];

    if (fieldsErrors.isNotEmpty) {
      emit(
        NotLoggedIn(
          registerErrors: fieldsErrors,
        ),
      );
    } else {
      emit(const LoginLoading());
      final dataState = await _createUserUseCase(
        CreateUserParams(
          user: event.user,
          password: event.password,
        ),
      );

      if (dataState is DataFailed) {
        _emitError(dataState, emit);
      }
    }
  }
}
