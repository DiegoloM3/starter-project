import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/search_history_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/search_history_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final AppDatabase _appDatabase;

  SearchHistoryRepositoryImpl(this._appDatabase);

  @override
  Future<List<SearchHistoryEntity>> getRecentSearches() async {
    final searches = await _appDatabase.searchHistoryDAO.getRecentSearches();
    return searches.map((search) => search.toEntity()).toList();
  }

  @override
  Future<void> saveSearch(String text) async {
    await _appDatabase.searchHistoryDAO.insertSearch(SearchHistoryModel(
      text: text,
      searchedAt: DateTime.now().millisecondsSinceEpoch,
    ));
    await _appDatabase.searchHistoryDAO.deleteOlderSearches();
  }

  @override
  Future<void> removeSearch(String text) {
    return _appDatabase.searchHistoryDAO.deleteSearch(text);
  }
}
