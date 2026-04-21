import 'package:equatable/equatable.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileIdle extends ProfileState {
  const ProfileIdle();
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
