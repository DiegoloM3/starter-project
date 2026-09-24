import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../entities/article_thumbnail.dart';

/// Contract for letting a journalist choose a cover from their device.
///
/// It is kept apart from `ArticleThumbnailRepository`, which *stores* images:
/// choosing a file and uploading one are different responsibilities backed by
/// different things — the device on one side, Cloud Storage on the other
/// (CG5, and the same reasoning as decision #7).
abstract class CoverImagePickerRepository {
  /// The image the journalist picked, or `null` if they backed out.
  ///
  /// Backing out is an ordinary answer, not a failure: somebody who opens the
  /// gallery and changes their mind has not done anything wrong.
  Future<DataState<ArticleThumbnailEntity?>> pickCoverImage();
}
