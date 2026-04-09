part of 'login_bloc.dart';

@immutable
sealed class LoginEvent extends Equatable {}

final class StartWatchingUser extends LoginEvent {
  @override
  List<Object?> get props => [];
}

final class CreateUserRequested extends LoginEvent {
  final UserEntity user;
  final String password;

  CreateUserRequested({required this.user, required this.password});

  @override
  List<Object?> get props => [user, password];
}

final class SignInWithEmailAndPasswordRequested extends LoginEvent {
  final String email;
  final String password;

  SignInWithEmailAndPasswordRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

final class SignOutRequested extends LoginEvent {
  @override
  List<Object?> get props => [];
}
