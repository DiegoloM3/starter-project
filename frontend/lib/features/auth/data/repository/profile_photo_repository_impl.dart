import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/profile_photo_repository.dart';
import 'package:news_app_clean_architecture/shared/media/data/data_sources/remote/image_storage_service.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/shared/firebase/data/data_sources/firebase_failure_mapper.dart';

/// Profile photos live at `media/avatars/{uid}.{ext}`, the only name the
/// Storage rules let that account write.
class ProfilePhotoRepositoryImpl implements ProfilePhotoRepository {
  final ImageStorageService _service;

  const ProfilePhotoRepositoryImpl(this._service);

  static const String folder = 'media/avatars';

  static String objectPathFor(String userId, LocalImage image) =>
      '$folder/$userId.${image.fileExtension}';

  @override
  Future<DataState<String>> upload({required String userId, required LocalImage image}) async {
    final errors = image.validate();
    if (errors.isNotEmpty) return DataFailed(Failure.validation(errors.first.message));
    return runGuarded(
      () => _service.upload(filePath: image.path, objectPath: objectPathFor(userId, image), contentType: image.mimeType),
      onError: FirebaseFailureMapper.map,
    );
  }
}
