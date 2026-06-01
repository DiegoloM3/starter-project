import 'package:equatable/equatable.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

class EditProfileImageUploading extends EditProfileState {
  const EditProfileImageUploading();
}

class EditProfileImageUploaded extends EditProfileState {
  final String avatarUrl;

  const EditProfileImageUploaded(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class EditProfileSuccess extends EditProfileState {
  final UserEntity updatedUser;

  const EditProfileSuccess(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}

class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class EditProfileAccountDeleted extends EditProfileState {
  const EditProfileAccountDeleted();
}
