import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/profile_update.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/profile_photo_repository.dart';

/// Changes the signed-in journalist's name and/or photo. The photo is
/// uploaded first so the profile only ever points at a file that exists.
class UpdateProfileUseCase implements UseCase<DataState<UserEntity>, ProfileUpdate> {
  final AuthRepository _authRepository;
  final ProfilePhotoRepository _profilePhotoRepository;

  const UpdateProfileUseCase(this._authRepository, this._profilePhotoRepository);

  @override
  Future<DataState<UserEntity>> call(ProfileUpdate params) async {
    final errors = params.validate();
    if (errors.isNotEmpty) {
      return DataFailed(Failure.validation(errors.first.message));
    }
    final imageErrors = params.photo?.validate() ?? const [];
    if (imageErrors.isNotEmpty) {
      return DataFailed(Failure.validation(imageErrors.first.message));
    }

    final user = _authRepository.currentUser;
    if (user == null) return const DataFailed(Failure.unauthenticated());
    if (params.isEmpty) return DataSuccess(user);

    String? photoUrl;
    final photo = params.photo;
    if (photo != null) {
      final upload = await _profilePhotoRepository.upload(userId: user.id, image: photo);
      if (upload is DataFailed<String>) return DataFailed(upload.failure);
      photoUrl = upload.dataOrNull;
    }

    return _authRepository.updateProfile(
      displayName: params.trimmedDisplayName,
      photoUrl: photoUrl,
    );
  }
}
