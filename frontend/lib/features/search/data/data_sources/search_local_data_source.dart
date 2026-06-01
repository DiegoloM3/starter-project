import 'package:shared_preferences/shared_preferences.dart';

abstract class SearchLocalDataSource {
  Future<List<String>> getRecentSearches();
  Future<void> saveRecentSearch(String query);
  Future<void> removeRecentSearch(String query);
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  static const String _key = 'recent_searches';
  static const int _maxItems = 8;

  @override
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final current = List<String>.from(prefs.getStringList(_key) ?? []);
    current.remove(query);
    current.insert(0, query);
    if (current.length > _maxItems) {
      current.removeRange(_maxItems, current.length);
    }
    await prefs.setStringList(_key, current);
  }

  @override
  Future<void> removeRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final current = List<String>.from(prefs.getStringList(_key) ?? []);
    current.remove(query);
    await prefs.setStringList(_key, current);
  }
}
