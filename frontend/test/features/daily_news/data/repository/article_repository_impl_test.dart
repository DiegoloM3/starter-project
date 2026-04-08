import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_local_datasource.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

// Pins spec 001 violations #3 (returns ArticleEntity, not ArticleModel) and
// #4 (delegates to ArticleLocalDataSource — no direct AppDatabase access).
//
// Only the local methods are exercised here. getNewsArticles depends on
// retrofit's generated HttpResponse type which is awkward to fake without a
// real Dio; that path is covered by the manual end-to-end run.

class _FakeLocalDataSource implements ArticleLocalDataSource {
  final List<ArticleEntity> store = [];
  int saveCallCount = 0;
  int removeCallCount = 0;
  int getCallCount = 0;

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    getCallCount++;
    return List.of(store);
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    saveCallCount++;
    store.add(article);
  }

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    removeCallCount++;
    store.removeWhere((a) => a == article);
  }
}

// Stub: never invoked by these tests, only required to satisfy the constructor.
class _UnusedNewsApiService implements NewsApiService {
  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('NewsApiService should not be called in this test');
}

void main() {
  late _FakeLocalDataSource localDataSource;
  late ArticleRepositoryImpl repository;

  setUp(() {
    localDataSource = _FakeLocalDataSource();
    repository = ArticleRepositoryImpl(_UnusedNewsApiService(), localDataSource);
  });

  group('ArticleRepositoryImpl - local operations', () {
    const article = ArticleEntity(
      id: 1,
      title: 'Test',
      description: 'D',
      url: 'U',
      content: 'C',
    );

    test('getSavedArticles returns List<ArticleEntity> (spec 001 #3)', () async {
      localDataSource.store.add(article);

      final result = await repository.getSavedArticles();

      // Type assertion is the meaningful check here — proves the violation fix.
      expect(result, isA<List<ArticleEntity>>());
      expect(result, [article]);
      expect(localDataSource.getCallCount, 1);
    });

    test('saveArticle delegates to the local data source (spec 001 #4)', () async {
      await repository.saveArticle(article);

      expect(localDataSource.saveCallCount, 1);
      expect(localDataSource.store, contains(article));
    });

    test('removeArticle delegates to the local data source (spec 001 #4)',
        () async {
      localDataSource.store.add(article);

      await repository.removeArticle(article);

      expect(localDataSource.removeCallCount, 1);
      expect(localDataSource.store, isEmpty);
    });
  });
}
