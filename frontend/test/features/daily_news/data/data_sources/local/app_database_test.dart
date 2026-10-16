import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_record.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Runs the generated database code on an in-memory SQLite database, to
/// check the code regenerated with floor_generator 1.5.
void main() {
  late AppDatabase database;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
  });

  tearDown(() => database.close());

  group('ArticleDao', () {
    const record = SavedArticleRecord(
      id: 1,
      author: 'Author',
      title: 'Breaking News!',
      description: 'Description',
      url: 'https://example.com',
      urlToImage: 'https://example.com/image.jpg',
      publishedAt: '2026-10-15T09:30:00Z',
      content: 'Content',
    );

    test('starts without saved articles', () async {
      expect(await database.articleDAO.getArticles(), isEmpty);
    });

    test('saves an article with all its fields', () async {
      await database.articleDAO.insertArticle(record);

      final savedArticles = await database.articleDAO.getArticles();

      expect(savedArticles.single.toModel(), record.toModel());
    });

    test('removes a saved article', () async {
      await database.articleDAO.insertArticle(record);

      await database.articleDAO.deleteArticle(record);

      expect(await database.articleDAO.getArticles(), isEmpty);
    });
  });
}
