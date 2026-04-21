import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/entities/auth_user.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

class SessionAuthenticating extends SessionState {
  const SessionAuthenticating();
}

class SessionAuthenticated extends SessionState {
  final AuthUserEntity user;
  const SessionAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class SessionFailure extends SessionState {
  final String message;
  const SessionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
