import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/cover_image_picker_repository.dart';

import 'article_fixtures.dart';

/// Hand written test double for [CoverImagePickerRepository].
///
/// It defaults to a valid image so that a test only has to say something when
/// it cares about the picker: cancelling, or picking something the rules
/// reject.
class FakeCoverImagePickerRepository implements CoverImagePickerRepository {
  DataState<ArticleThumbnailEntity?>? pickResult;

  int pickCallCount = 0;

  /// Nobody picked anything, which is an ordinary answer.
  void willBeCancelled() => pickResult = const DataSuccess(null);

  void willPick(ArticleThumbnailEntity image) =>
      pickResult = DataSuccess(image);

  @override
  Future<DataState<ArticleThumbnailEntity?>> pickCoverImage() async {
    pickCallCount++;

    return pickResult ?? DataSuccess(thumbnail());
  }
}
