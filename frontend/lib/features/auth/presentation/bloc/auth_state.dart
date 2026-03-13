import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Enum representing possible authentication failure reasons
enum AuthFailure {
  invalidEmail,
  wrongPassword,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  networkError,
  unknown,
}

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  final UserEntity? user;
  final String? errorMessage;
  final AuthFailure? failure;

  const AuthState({
    this.user,
    this.errorMessage,
    this.failure,
  });

  @override
  List<Object?> get props => [user, errorMessage, failure];
}

/// Initial state before any authentication check
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State while authentication operation is in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is successfully authenticated
class Authenticated extends AuthState {
  const Authenticated(UserEntity user) : super(user: user);

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State when authentication operation fails
class AuthError extends AuthState {
  const AuthError({
    required String message,
    AuthFailure? failure,
  }) : super(errorMessage: message, failure: failure);

  @override
  List<Object?> get props => [errorMessage, failure];
}

/// State when profile update is in progress
class ProfileUpdating extends AuthState {
  const ProfileUpdating(UserEntity user) : super(user: user);
}

/// State when profile update succeeds
class ProfileUpdated extends AuthState {
  const ProfileUpdated(UserEntity user) : super(user: user);
}

/// State when password change is in progress
class PasswordChanging extends AuthState {
  const PasswordChanging(UserEntity user) : super(user: user);
}

/// State when password change succeeds
class PasswordChanged extends AuthState {
  const PasswordChanged(UserEntity user) : super(user: user);
}

/// State when password change fails
class PasswordChangeError extends AuthState {
  const PasswordChangeError({
    required String message,
    UserEntity? user,
  }) : super(errorMessage: message, user: user);
}

/// State when sending password reset email
class ForgotPasswordLoading extends AuthState {
  const ForgotPasswordLoading();
}

/// State when password reset email sent successfully
class ForgotPasswordEmailSent extends AuthState {
  const ForgotPasswordEmailSent();
}

/// State when password reset email fails
class ForgotPasswordError extends AuthState {
  const ForgotPasswordError({required String message})
      : super(errorMessage: message);
}
