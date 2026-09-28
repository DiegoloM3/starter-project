part of 'profile_bloc.dart';

/// UI states emitted by [ProfileBloc].
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileDone extends ProfileState {
  final String userId;
  final String email;
  final String displayName;
  final String? photoUrl;

  const ProfileDone({
    required this.userId,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, email, displayName, photoUrl];
}

class ProfileSaving extends ProfileState {
  const ProfileSaving();
}

class ProfileSaved extends ProfileState {
  const ProfileSaved();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
