import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// The headlines the app reads, and the ones the reader chose to keep.
///
/// Every method answers with a [DataState]: the saved articles live in a
/// local database, which can fail just as an API can, and a caller that is
/// handed a bare `Future` has nowhere to put that failure.
abstract class ArticleRepository {
  /// Headlines for [category]. The section is chosen per request: the API
  /// returns no category on an article, so there is nothing to filter locally.
  Future<DataState<List<ArticleEntity>>> getNewsArticles({
    NewsCategory category = NewsCategory.general,
  });

  /// The articles the reader kept, most recently stored last.
  Future<DataState<List<ArticleEntity>>> getSavedArticles();

  /// Keeps [article]. Saving one that is already kept changes nothing.
  Future<DataState<void>> saveArticle(ArticleEntity article);

  /// Drops [article] from the kept ones.
  Future<DataState<void>> removeArticle(ArticleEntity article);
}
