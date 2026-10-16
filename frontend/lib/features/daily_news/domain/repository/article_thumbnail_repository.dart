import 'package:news_app_clean_architecture/core/resources/data_state.dart';

abstract class ArticleThumbnailRepository {
  /// Returns the local path of the picked image, or `null` when the user
  /// closes the gallery without picking one.
  Future<DataState<String?>> pickThumbnailFromGallery();
}
