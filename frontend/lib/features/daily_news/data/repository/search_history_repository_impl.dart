import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/search_history_local_data_source/search_history_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final SearchHistoryLocalDataSource _dataSource;
  SearchHistoryRepositoryImpl({required SearchHistoryLocalDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<List<String>> getHistory() => _dataSource.getHistory();
  @override
  Future<void> addTerm(String term) => _dataSource.addTerm(term);
  @override
  Future<void> removeTerm(String term) => _dataSource.removeTerm(term);
  @override
  Future<void> clearHistory() => _dataSource.clearHistory();
}