import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetArticleUseCase implements UseCase<DataState<NewsPage>, NewsQuery> {
  final ArticleRepository _articleRepository;

  GetArticleUseCase(this._articleRepository);

  @override
  Future<DataState<NewsPage>> call({NewsQuery? params}) {
    return _articleRepository.getNewsArticles(params ?? const NewsQuery());
  }
}
