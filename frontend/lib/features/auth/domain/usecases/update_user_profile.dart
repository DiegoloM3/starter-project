import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/user_profile_repository.dart';

/// Profile-update input required by [UpdateUserProfile].
class UpdateUserProfileParams {
  final String userId;
  final String displayName;
  final File? avatarFile;

  const UpdateUserProfileParams({
    required this.userId,
    required this.displayName,
    this.avatarFile,
  });
}

/// Single operation: updates avatar, profile doc, and auth profile.
class UpdateUserProfile
    implements UseCase<DataState<UserProfileEntity>, UpdateUserProfileParams> {
  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;

  UpdateUserProfile(this._authRepository, this._userProfileRepository);

  @override
  Future<DataState<UserProfileEntity>> call(
      {UpdateUserProfileParams? params}) async {
    if (params == null) {
      return const DataGenericFailed('Missing profile parameters');
    }

    // Upload once and reuse the URL for both stores. The Auth mirror goes
    // first: if it fails, the Firestore write never happens, so the two
    // stores cannot diverge.
    final uploadResult = await _userProfileRepository.uploadAvatar(
      params.userId,
      params.avatarFile,
    );
    if (uploadResult is! DataSuccess) {
      return DataGenericFailed(
        uploadResult.errorMessage ??
            uploadResult.error?.toString() ??
            'Could not upload your avatar.',
      );
    }

    final authResult = await _authRepository.updateCurrentUserProfile(
      displayName: params.displayName,
      photoUrl: uploadResult.data,
    );
    if (authResult is! DataSuccess) {
      return DataGenericFailed(
        authResult.errorMessage ??
            authResult.error?.toString() ??
            'Could not update your account.',
      );
    }

    return await _userProfileRepository.updateUserProfile(
      userId: params.userId,
      displayName: params.displayName,
      photoUrl: uploadResult.data,
    );
  }
}
