import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignUpRequested({required this.email, required this.password});
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthStateChanged extends AuthEvent {
  final AuthUserEntity? user;

  const AuthStateChanged({this.user});
}
