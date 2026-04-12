import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/news_api_cache_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

void main() {
  late AppDatabase database;
  late NewsApiCacheService cacheService;

  setUp(() async {
    database = await $FroomAppDatabase.inMemoryDatabaseBuilder().build();
    cacheService = NewsApiCacheService(database);
    await cacheService.ensureTableCreated();
  });

  tearDown(() async {
    await database.close();
  });

  group('NewsApiCacheService', () {
    test('getCachedArticles returns empty list when no cache exists', () async {
      final result = await cacheService.getCachedArticles();
      expect(result, isEmpty);
    });

    test('cacheArticles stores articles and getCachedArticles retrieves them',
        () async {
      const articles = [
        ArticleModel(
          author: 'Author 1',
          title: 'Title 1',
          description: 'Desc 1',
          url: 'https://example.com/1',
          urlToImage: 'https://img.com/1.jpg',
          publishedAt: '2026-01-01',
          content: 'Content 1',
        ),
        ArticleModel(
          author: 'Author 2',
          title: 'Title 2',
          description: 'Desc 2',
          url: 'https://example.com/2',
          urlToImage: 'https://img.com/2.jpg',
          publishedAt: '2026-01-02',
          content: 'Content 2',
        ),
      ];

      await cacheService.cacheArticles(articles);
      final result = await cacheService.getCachedArticles();

      expect(result.length, 2);
      expect(result[0].title, 'Title 1');
      expect(result[0].author, 'Author 1');
      expect(result[1].title, 'Title 2');
      expect(result[1].url, 'https://example.com/2');
    });

    test('cacheArticles replaces existing cache', () async {
      const firstBatch = [
        ArticleModel(title: 'Old Article', url: 'https://old.com'),
      ];
      const secondBatch = [
        ArticleModel(title: 'New Article 1', url: 'https://new1.com'),
        ArticleModel(title: 'New Article 2', url: 'https://new2.com'),
      ];

      await cacheService.cacheArticles(firstBatch);
      await cacheService.cacheArticles(secondBatch);
      final result = await cacheService.getCachedArticles();

      expect(result.length, 2);
      expect(result[0].title, 'New Article 1');
      expect(result[1].title, 'New Article 2');
    });

    test('cacheArticles with empty list clears cache', () async {
      const articles = [
        ArticleModel(title: 'Article', url: 'https://example.com'),
      ];

      await cacheService.cacheArticles(articles);
      await cacheService.cacheArticles([]);
      final result = await cacheService.getCachedArticles();

      expect(result, isEmpty);
    });

    test('cacheArticles handles null fields gracefully', () async {
      const articles = [
        ArticleModel(),
      ];

      await cacheService.cacheArticles(articles);
      final result = await cacheService.getCachedArticles();

      expect(result.length, 1);
      expect(result[0].title, isNull);
      expect(result[0].author, isNull);
    });
  });
}
