import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../entities/article_thumbnail.dart';

abstract class ThumbnailPickerRepository {
  /// Opens the device gallery (never the camera). Succeeds with `null` when the journalist cancels.
  Future<DataState<ArticleThumbnailEntity?>> pickThumbnailFromGallery();
}
