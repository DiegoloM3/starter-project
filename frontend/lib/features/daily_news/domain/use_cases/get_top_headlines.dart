import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/news_repository.dart';

/// Headlines from the news provider only, e.g. for a category chip or the
/// Daily Brief.
class GetTopHeadlinesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, NewsQuery> {
  final NewsRepository _newsRepository;

  const GetTopHeadlinesUseCase(this._newsRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(NewsQuery params) {
    return _newsRepository.getTopHeadlines(params);
  }
}
