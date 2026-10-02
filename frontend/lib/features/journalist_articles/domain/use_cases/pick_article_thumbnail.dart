import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_thumbnail_repository.dart';

class PickArticleThumbnailUseCase
    implements UseCase<DataState<ArticleThumbnailEntity?>, void> {
  final ArticleThumbnailRepository _articleThumbnailRepository;

  PickArticleThumbnailUseCase(this._articleThumbnailRepository);

  @override
  Future<DataState<ArticleThumbnailEntity?>> call({void params}) {
    return _articleThumbnailRepository.pickThumbnailFromGallery();
  }
}
