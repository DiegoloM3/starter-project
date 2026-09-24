import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_failures.dart';
import '../entities/article_thumbnail.dart';
import '../repository/cover_image_picker_repository.dart';

/// Gets a cover image the rules will accept.
///
/// It picks *and* judges: an image that breaks the size or format rules is
/// reported here, on the device, instead of travelling to Cloud Storage just
/// to be refused by `backend/storage.rules`.
class PickArticleCoverUseCase
    implements UseCase<DataState<ArticleThumbnailEntity?>, NoParams> {
  final CoverImagePickerRepository _pickerRepository;

  const PickArticleCoverUseCase(this._pickerRepository);

  @override
  Future<DataState<ArticleThumbnailEntity?>> call(NoParams params) async {
    final result = await _pickerRepository.pickCoverImage();

    if (result is! DataSuccess<ArticleThumbnailEntity?>) {
      return result;
    }

    final thumbnail = result.data;

    // Nobody picked anything, which is not a failure.
    if (thumbnail == null) {
      return const DataSuccess(null);
    }

    final validationErrors = thumbnail.validate();

    if (validationErrors.isNotEmpty) {
      return DataFailed(ThumbnailValidationException(validationErrors));
    }

    return DataSuccess(thumbnail);
  }
}
