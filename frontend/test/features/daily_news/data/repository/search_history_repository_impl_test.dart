import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/search_history_repository_impl.dart';

/// Runs against a real in-memory SQLite database, so the hand-written Floor
/// code (see REPORT.md: the generator no longer runs) is exercised for real.
void main() {
  late AppDatabase database;
  late SearchHistoryRepositoryImpl repository;

  setUp(() async {
    database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    repository = SearchHistoryRepositoryImpl(database);
  });

  tearDown(() => database.close());

  Future<List<String>> recent() async => [
        for (final entry in await repository.getRecentSearches()) entry.text,
      ];

  test('lists searches most recent first', () async {
    await repository.saveSearch('climate');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repository.saveSearch('elections');

    expect(await recent(), ['elections', 'climate']);
  });

  test('searching again moves it to the top instead of repeating it', () async {
    await repository.saveSearch('climate');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repository.saveSearch('elections');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repository.saveSearch('climate');

    expect(await recent(), ['climate', 'elections']);
  });

  test('removes one search and leaves the rest', () async {
    await repository.saveSearch('climate');
    await repository.saveSearch('elections');

    await repository.removeSearch('climate');

    expect(await recent(), ['elections']);
  });

  test('keeps only the 10 most recent', () async {
    for (var i = 0; i < 12; i++) {
      await repository.saveSearch('search $i');
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }

    final searches = await recent();
    expect(searches, hasLength(10));
    expect(searches.first, 'search 11');
    expect(searches, isNot(contains('search 0')));
  });
}
