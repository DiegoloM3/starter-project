

abstract class SearchHistoryRepository {
  Future<List<String>> getHistory();
  Future<void> addTerm(String term);
  Future<void> removeTerm(String term);
  Future<void> clearHistory();
}