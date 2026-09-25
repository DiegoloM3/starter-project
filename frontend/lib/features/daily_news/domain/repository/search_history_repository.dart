import 'package:news_app_clean_architecture/features/daily_news/domain/entities/search_history_entity.dart';

/// The reader's recent searches, kept on this phone only.
abstract class SearchHistoryRepository {
  /// Most recent first.
  Future<List<SearchHistoryEntity>> getRecentSearches();

  /// Adds [text], or moves it to the top if it's already there.
  Future<void> saveSearch(String text);

  Future<void> removeSearch(String text);
}
