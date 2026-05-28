import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

abstract class AuthState extends Equatable {
  final AuthUserEntity? user;
  final AppException? error;

  const AuthState({this.user, this.error});

  @override
  List<Object?> get props => [user, error];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(AuthUserEntity user) : super(user: user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  const AuthFailure(AppException error) : super(error: error);
}
