import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/stream_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetPublishedArticlesUseCase
    implements StreamUseCase<DataState<List<ArticleEntity>>, void> {
  final ArticleRepository _articleRepository;

  GetPublishedArticlesUseCase(this._articleRepository);

  @override
  Stream<DataState<List<ArticleEntity>>> call({void params}) {
    return _articleRepository.getPublishedArticles();
  }
}
