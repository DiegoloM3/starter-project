import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

abstract class ArticleThumbnailRepository {
  /// Returns `null` inside a [DataSuccess] when the journalist closes the gallery without choosing an image.
  Future<DataState<ArticleThumbnailEntity?>> pickThumbnailFromGallery();
}
