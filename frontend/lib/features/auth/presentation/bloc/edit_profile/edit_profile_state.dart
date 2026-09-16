part of 'edit_profile_cubit.dart';

enum EditProfileStatus { editing, submitting, success, failure }

class EditProfileState extends Equatable {
  final UserEntity original;
  final String displayName;

  /// A new photo picked on the device, not uploaded yet.
  final LocalImage? photo;
  final EditProfileStatus status;
  final CredentialValidationError? displayNameError;
  final Failure? failure;

  const EditProfileState({
    required this.original,
    required this.displayName,
    this.photo,
    this.status = EditProfileStatus.editing,
    this.displayNameError,
    this.failure,
  });

  bool get isSubmitting => status == EditProfileStatus.submitting;

  bool get nameChanged => displayName.trim() != (original.displayName ?? '');

  /// Save is possible once something differs from the stored profile.
  bool get hasChanges => nameChanged || photo != null;

  /// Only the fields that changed are sent.
  ProfileUpdate get update => ProfileUpdate(
        displayName: nameChanged ? displayName : null,
        photo: photo,
      );

  EditProfileState copyWith({
    String? displayName,
    LocalImage? photo,
    EditProfileStatus? status,
    CredentialValidationError? displayNameError,
    Failure? failure,
  }) {
    return EditProfileState(
      original: original,
      displayName: displayName ?? this.displayName,
      photo: photo ?? this.photo,
      status: status ?? this.status,
      displayNameError: displayNameError,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [original, displayName, photo, status, displayNameError, failure];
}
