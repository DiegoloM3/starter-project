import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/profile_update.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/update_profile.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/shared/media/domain/use_cases/pick_image.dart';

part 'edit_profile_state.dart';

/// The Edit profile form: display name and photo.
class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfileUseCase _updateProfile;
  final PickImageUseCase _pickPhoto;

  EditProfileCubit(this._updateProfile, this._pickPhoto, {required UserEntity user})
      : super(EditProfileState(original: user, displayName: user.displayName ?? ''));

  void displayNameChanged(String value) =>
      emit(state.copyWith(displayName: value, status: EditProfileStatus.editing));

  Future<void> pickPhoto() async {
    final result = await _pickPhoto(const NoParams());
    if (isClosed) return;
    switch (result) {
      case DataSuccess(:final data):
        if (data != null) emit(state.copyWith(photo: data, status: EditProfileStatus.editing));
      case DataFailed(:final failure):
        emit(state.copyWith(failure: failure));
    }
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    final update = state.update;
    final errors = update.validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(status: EditProfileStatus.failure, displayNameError: errors.first));
      return;
    }

    emit(state.copyWith(status: EditProfileStatus.submitting));
    final result = await _updateProfile(update);
    if (isClosed) return;
    switch (result) {
      case DataSuccess():
        emit(state.copyWith(status: EditProfileStatus.success));
      case DataFailed(:final failure):
        emit(state.copyWith(status: EditProfileStatus.failure, failure: failure));
    }
  }
}
