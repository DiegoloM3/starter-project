import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/search_history_model.dart';

@dao
abstract class SearchHistoryDao {
  static const keep = 10;

  @Query('SELECT * FROM search_history ORDER BY searchedAt DESC LIMIT 10')
  Future<List<SearchHistoryModel>> getRecentSearches();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSearch(SearchHistoryModel search);

  @Query('DELETE FROM search_history WHERE text = :text')
  Future<void> deleteSearch(String text);

  /// Keeps only the [keep] most recent, so the table never grows unbounded.
  @Query('DELETE FROM search_history WHERE text NOT IN '
      '(SELECT text FROM search_history ORDER BY searchedAt DESC LIMIT 10)')
  Future<void> deleteOlderSearches();
}
