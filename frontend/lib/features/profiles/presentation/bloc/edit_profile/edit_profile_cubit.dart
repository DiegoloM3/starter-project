import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/exceptions/profile_exceptions.dart';
import '../../../domain/params/update_profile_params.dart';
import '../../../domain/usecases/update_profile.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfileUseCase _updateProfileUseCase;

  EditProfileCubit(this._updateProfileUseCase) : super(const EditProfileState());

  /// [newPhoto] is null to keep the current photo.
  Future<void> save({
    required String firstName,
    required String lastName,
    required String bio,
    Uint8List? newPhoto,
  }) async {
    emit(const EditProfileState(status: EditProfileStatus.saving));
    final params = UpdateProfileParams(firstName: firstName, lastName: lastName, bio: bio, newPhoto: newPhoto);
    final error = (await _updateProfileUseCase(params)).error;
    emit(switch (error) {
      null => const EditProfileState(status: EditProfileStatus.success),
      ProfileValidationException(:final errors) => EditProfileState(
        status: EditProfileStatus.failure,
        validationErrors: errors,
      ),
      _ => const EditProfileState(status: EditProfileStatus.failure),
    });
  }
}
