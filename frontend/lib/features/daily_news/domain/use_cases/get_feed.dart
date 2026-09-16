import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/news_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';

/// The home timeline: provider headlines and journalist articles, newest
/// first. Both sources are queried concurrently.
class GetFeedUseCase implements UseCase<DataState<FeedEntity>, NewsQuery> {
  final NewsRepository _newsRepository;
  final UserArticleRepository _userArticleRepository;

  const GetFeedUseCase(this._newsRepository, this._userArticleRepository);

  @override
  Future<DataState<FeedEntity>> call(NewsQuery params) async {
    final results = await Future.wait([
      _newsRepository.getTopHeadlines(params),
      _userArticleRepository.getArticles(),
    ]);

    return FeedEntity.merge(remote: results[0], user: results[1]);
  }
}
