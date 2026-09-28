import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryLocalDataSource {
  static const _key = 'search_history';
  static const _maxItems = 10;

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> addTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    history.remove(term);
    history.insert(0, term);
    if (history.length > _maxItems) history.removeRange(_maxItems, history.length);
    await prefs.setStringList(_key, history);
  }

  Future<void> removeTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    history.remove(term);
    await prefs.setStringList(_key, history);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}