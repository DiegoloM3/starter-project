import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/exceptions/upload_article_exceptions.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/refresh_author_snapshots.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/password_change.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/profile_photo.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/update_display_name.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/update_password.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/update_profile_photo.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/profile_state.dart';

class ProfileDeps {
  final UpdateDisplayNameUseCase updateDisplayName;
  final UpdatePasswordUseCase updatePassword;
  final UpdateProfilePhotoUseCase updateProfilePhoto;
  final RefreshAuthorSnapshotsUseCase refreshAuthorSnapshots;

  const ProfileDeps({
    required this.updateDisplayName,
    required this.updatePassword,
    required this.updateProfilePhoto,
    required this.refreshAuthorSnapshots,
  });
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileDeps _deps;

  ProfileCubit(this._deps) : super(const ProfileIdle());

  Future<AuthUserEntity?> updateDisplayName(String name) async {
    emit(const ProfileUpdating());
    try {
      final user = await _deps.updateDisplayName(params: name);
      await _deps.refreshAuthorSnapshots();
      emit(const ProfileIdle());
      return user;
    } on AuthException catch (e) {
      emit(ProfileError(e.message));
      return null;
    } on UploadArticleException catch (e) {
      emit(ProfileError(e.message));
      return null;
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const ProfileUpdating());
    try {
      await _deps.updatePassword(
          params: PasswordChange(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ));
      emit(const ProfileIdle());
    } on AuthException catch (e) {
      emit(ProfileError(e.message));
      rethrow;
    }
  }

  Future<AuthUserEntity?> updateProfilePhoto({
    required List<int> bytes,
    required String fileName,
  }) async {
    emit(const ProfileUpdating());
    try {
      final user = await _deps.updateProfilePhoto(
        params: ProfilePhoto(bytes: bytes, fileName: fileName),
      );
      await _deps.refreshAuthorSnapshots();
      emit(const ProfileIdle());
      return user;
    } on AuthException catch (e) {
      emit(ProfileError(e.message));
      return null;
    } on UploadArticleException catch (e) {
      emit(ProfileError(e.message));
      return null;
    }
  }
}
