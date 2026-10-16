import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_thumbnail_repository.dart';

class PickArticleThumbnailUseCase implements UseCase<DataState<String?>, void> {
  final ArticleThumbnailRepository _articleThumbnailRepository;

  PickArticleThumbnailUseCase(this._articleThumbnailRepository);

  @override
  Future<DataState<String?>> call({void params}) {
    return _articleThumbnailRepository.pickThumbnailFromGallery();
  }
}
