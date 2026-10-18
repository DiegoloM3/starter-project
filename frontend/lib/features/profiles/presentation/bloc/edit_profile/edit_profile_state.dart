import 'package:equatable/equatable.dart';

import '../../../domain/params/update_profile_params.dart';

enum EditProfileStatus { editing, saving, success, failure }

class EditProfileState extends Equatable {
  final EditProfileStatus status;

  /// Empty on a failure means that something unexpected happened.
  final Set<ProfileValidationError> validationErrors;

  const EditProfileState({this.status = EditProfileStatus.editing, this.validationErrors = const {}});

  bool get isSaving => status == EditProfileStatus.saving;

  @override
  List<Object?> get props => [status, validationErrors];
}
