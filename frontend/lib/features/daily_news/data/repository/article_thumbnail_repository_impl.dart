import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/device/gallery_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_thumbnail_repository.dart';

class ArticleThumbnailRepositoryImpl implements ArticleThumbnailRepository {
  final GalleryService _galleryService;

  ArticleThumbnailRepositoryImpl(this._galleryService);

  @override
  Future<DataState<String?>> pickThumbnailFromGallery() async {
    try {
      return DataSuccess(await _galleryService.pickImage());
    } on Exception catch (exception) {
      return DataFailed(exception);
    }
  }
}
