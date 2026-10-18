import '../../../../core/resources/data_state.dart';
import '../entities/article.dart';

class ReadingHistoryLimits {
  /// The profile shows the last 10 articles viewed, and older views are deleted.
  static const int maxEntries = 10;
}

/// Articles viewed by the signed in user. Viewing an article again moves it to the top.
abstract class ReadingHistoryRepository {
  Future<DataState<void>> recordView(String articleId);

  Future<DataState<void>> deleteViewsBeyond(int count);

  /// Most recently viewed first.
  Future<DataState<List<ArticleEntity>>> getRecentlyViewed(int count);
}
