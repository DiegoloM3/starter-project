import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_failures.dart';
import '../params/upload_article_thumbnail_params.dart';
import '../repository/article_thumbnail_repository.dart';

/// Uploads the image of an article and returns the URL to store in its
/// `thumbnailURL` field.
///
/// Size and format are checked here so that an invalid image never leaves the
/// device.
class UploadArticleThumbnailUseCase
    implements UseCase<DataState<String>, UploadArticleThumbnailParams> {
  final ArticleThumbnailRepository _thumbnailRepository;

  const UploadArticleThumbnailUseCase(this._thumbnailRepository);

  @override
  Future<DataState<String>> call(UploadArticleThumbnailParams params) async {
    final validationErrors = params.thumbnail.validate();

    if (validationErrors.isNotEmpty) {
      return DataFailed(ThumbnailValidationException(validationErrors));
    }

    return _thumbnailRepository.uploadThumbnail(
      userId: params.userId,
      thumbnail: params.thumbnail,
    );
  }
}
