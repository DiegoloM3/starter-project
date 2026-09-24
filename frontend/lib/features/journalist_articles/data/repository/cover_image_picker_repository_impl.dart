import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';

import '../../domain/entities/article_thumbnail.dart';
import '../../domain/repository/cover_image_picker_repository.dart';
import '../data_sources/local/image_picker_service.dart';

/// Device implementation of [CoverImagePickerRepository].
class CoverImagePickerRepositoryImpl implements CoverImagePickerRepository {
  final ImagePickerService _pickerService;

  const CoverImagePickerRepositoryImpl(this._pickerService);

  @override
  Future<DataState<ArticleThumbnailEntity?>> pickCoverImage() async {
    try {
      final picked = await _pickerService.pickImage();

      if (picked == null) {
        return const DataSuccess(null);
      }

      return DataSuccess(
        ArticleThumbnailEntity(
          fileName: picked.fileName,
          bytes: picked.bytes,
        ),
      );
    } on RemoteException catch (error) {
      return DataFailed(error);
    } catch (error) {
      // As everywhere else: an error that escapes a repository does not
      // surface, it leaves the caller waiting forever.
      return DataFailed(error);
    }
  }
}
