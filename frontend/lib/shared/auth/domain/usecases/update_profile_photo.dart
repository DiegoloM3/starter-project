import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/profile_photo.dart';

class UpdateProfilePhotoUseCase
    implements UseCase<AuthUserEntity, ProfilePhoto> {
  final AuthRepository _repository;

  UpdateProfilePhotoUseCase(this._repository);

  @override
  Future<AuthUserEntity> call({ProfilePhoto? params}) {
    if (params == null || params.bytes.isEmpty) {
      throw const AuthUnknownException('Pick an image first.');
    }
    return _repository.updateProfilePhoto(params);
  }
}
