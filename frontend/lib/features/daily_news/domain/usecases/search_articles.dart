import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class SearchArticlesUseCase
    implements UseCase<DataState<NewsPage>, SearchQuery> {
  final ArticleRepository _articleRepository;

  SearchArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<NewsPage>> call({SearchQuery? params}) {
    if (params == null || params.text.trim().isEmpty) {
      return Future.value(
          const DataSuccess(NewsPage(articles: [], hasMore: false)));
    }
    return _articleRepository.searchArticles(params);
  }
}
