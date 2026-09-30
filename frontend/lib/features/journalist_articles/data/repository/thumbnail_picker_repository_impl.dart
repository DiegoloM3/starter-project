import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/entities/article_thumbnail.dart';
import '../../domain/repository/thumbnail_picker_repository.dart';
import '../data_sources/local/gallery_image_data_source.dart';

class ThumbnailPickerRepositoryImpl implements ThumbnailPickerRepository {
  final GalleryImageDataSource _galleryImageDataSource;

  ThumbnailPickerRepositoryImpl(this._galleryImageDataSource);

  @override
  Future<DataState<ArticleThumbnailEntity?>> pickThumbnailFromGallery() async {
    try {
      final thumbnail = await _galleryImageDataSource.pickImage();
      return DataSuccess(thumbnail?.toEntity());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }
}
