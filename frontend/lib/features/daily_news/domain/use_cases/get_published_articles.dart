import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/published_article_repository.dart';

class GetPublishedArticlesUseCase
    implements UseCase<DataState<List<PublishedArticleEntity>>, void> {
  final PublishedArticleRepository _publishedArticleRepository;

  GetPublishedArticlesUseCase(this._publishedArticleRepository);

  @override
  Future<DataState<List<PublishedArticleEntity>>> call({void params}) {
    return _publishedArticleRepository.getPublishedArticles();
  }
}
