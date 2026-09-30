import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_thumbnail.dart';
import '../repository/thumbnail_picker_repository.dart';

class PickThumbnailFromGalleryUseCase implements UseCase<DataState<ArticleThumbnailEntity?>, void> {
  final ThumbnailPickerRepository _thumbnailPickerRepository;

  PickThumbnailFromGalleryUseCase(this._thumbnailPickerRepository);

  @override
  Future<DataState<ArticleThumbnailEntity?>> call({void params}) {
    return _thumbnailPickerRepository.pickThumbnailFromGallery();
  }
}
