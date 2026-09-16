import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/thumbnail_reference.dart';

/// Binary storage for article thumbnails.
abstract interface class ThumbnailStorageRepository {
  /// Uploads the image and returns where it can be read from and deleted at.
  Future<DataState<ThumbnailReference>> upload(LocalImage image);

  Future<DataState<void>> delete(String path);
}
