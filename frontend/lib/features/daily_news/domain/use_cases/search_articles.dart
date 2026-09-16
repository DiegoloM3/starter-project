import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/news_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';

/// Full-text search across the provider and our own articles.
///
/// A blank query yields an empty feed without touching any source.
class SearchArticlesUseCase implements UseCase<DataState<FeedEntity>, String> {
  final NewsRepository _newsRepository;
  final UserArticleRepository _userArticleRepository;

  const SearchArticlesUseCase(this._newsRepository, this._userArticleRepository);

  @override
  Future<DataState<FeedEntity>> call(String params) async {
    final query = params.trim();
    if (query.isEmpty) {
      return const DataSuccess(FeedEntity.empty);
    }

    final results = await Future.wait([
      _newsRepository.searchArticles(query),
      _userArticleRepository.searchArticles(query),
    ]);

    return FeedEntity.merge(remote: results[0], user: results[1]);
  }
}
