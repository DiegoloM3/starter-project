import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_user_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@injectable
/// UI state machine for viewing/updating the current user's profile.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdateUserProfile _updateUserProfile;

  ProfileBloc(this._getCurrentUserUseCase, this._updateUserProfile)
      : super(const ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<SaveProfile>(_onSaveProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final user = await _getCurrentUserUseCase();
    if (user is! DataSuccess || user.data == null) {
      emit(const ProfileError('Please log in to edit your profile.'));
      return;
    }

    emit(ProfileDone(
      userId: user.data!.id,
      email: user.data!.email,
      displayName: user.data!.displayName ?? '',
      photoUrl: user.data!.photoUrl,
    ));
  }

  Future<void> _onSaveProfile(
    SaveProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final name = event.displayName.trim();
    if (name.isEmpty) {
      emit(const ProfileError('Name cannot be empty.'));
      return;
    }

    emit(const ProfileSaving());

    final result = await _updateUserProfile(
      params: UpdateUserProfileParams(
        userId: event.userId,
        displayName: name,
        avatarFile: event.avatarFile,
      ),
    );

    if (result is DataSuccess) {
      emit(const ProfileSaved());
    } else {
      emit(ProfileError(
        result.errorMessage ?? result.error?.toString() ?? 'Unknown error.',
      ));
    }
  }
}
