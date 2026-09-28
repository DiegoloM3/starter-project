part of 'profile_bloc.dart';

/// Events consumed by [ProfileBloc].
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class SaveProfile extends ProfileEvent {
  final String userId;
  final String displayName;
  final File? avatarFile;

  const SaveProfile({
    required this.userId,
    required this.displayName,
    this.avatarFile,
  });

  @override
  List<Object?> get props => [userId, displayName, avatarFile?.path];
}
