import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/article_thumbnail_gallery_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_thumbnail_repository.dart';

class ArticleThumbnailRepositoryImpl implements ArticleThumbnailRepository {
  final ArticleThumbnailGalleryDataSource _galleryDataSource;

  ArticleThumbnailRepositoryImpl(this._galleryDataSource);

  @override
  Future<DataState<ArticleThumbnailEntity?>> pickThumbnailFromGallery() async {
    try {
      final thumbnail = await _galleryDataSource.pickThumbnail();
      return DataSuccess(thumbnail?.toEntity());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }
}
