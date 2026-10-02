import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

/// The session kept on the phone has not been read yet.
class SessionUnknown extends SessionState {
  const SessionUnknown();
}

class SessionSignedIn extends SessionState {
  final UserEntity user;

  const SessionSignedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class SessionSignedOut extends SessionState {
  const SessionSignedOut();
}
