part of 'login_bloc.dart';

@immutable
sealed class LoginState extends Equatable {
  final List<LoginFieldError> loginErrors;
  final List<RegisterFieldError> registerErrors;

  const LoginState({
    this.loginErrors = const [],
    this.registerErrors = const [],
  });

  @override
  List<Object?> get props => [loginErrors, registerErrors];
}

final class LoginInitial extends LoginState {
  @override
  List<Object?> get props => [];
}

final class LoginLoading extends LoginState {
  const LoginLoading({
    super.loginErrors = const [],
    super.registerErrors = const [],
  });

  @override
  List<Object?> get props => [
        loginErrors,
        registerErrors,
      ];
}

final class NotLoggedIn extends LoginState {
  const NotLoggedIn({super.loginErrors, super.registerErrors});

  @override
  List<Object?> get props => [loginErrors, registerErrors];
}

final class LoggedIn extends LoginState {
  final UserEntity user;

  const LoggedIn({
    required this.user,
    super.loginErrors = const [],
    super.registerErrors = const [],
  });

  @override
  List<Object?> get props => [user, loginErrors, registerErrors];
}

final class LoginError extends LoginState {
  final String message;

  const LoginError({
    required this.message,
    super.loginErrors = const [],
    super.registerErrors = const [],
  });

  @override
  List<Object?> get props => [message, loginErrors, registerErrors];
}
