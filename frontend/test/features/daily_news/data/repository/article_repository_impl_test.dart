import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_record.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_headlines_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class MockNewsHeadlinesService extends Mock implements NewsHeadlinesService {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockArticleDao extends Mock implements ArticleDao {}

void main() {
  late MockNewsHeadlinesService newsHeadlinesService;
  late MockArticleDao articleDao;
  late ArticleRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const SavedArticleRecord());
  });

  setUp(() {
    newsHeadlinesService = MockNewsHeadlinesService();
    articleDao = MockArticleDao();
    final appDatabase = MockAppDatabase();
    when(() => appDatabase.articleDAO).thenReturn(articleDao);
    repository = ArticleRepositoryImpl(newsHeadlinesService, appDatabase);
  });

  group('ArticleRepositoryImpl', () {
    test('returns the news articles as entities', () async {
      when(() => newsHeadlinesService.getTopHeadlines())
          .thenAnswer((_) async => const [ArticleModel(title: 'Breaking News!')]);

      final result = await repository.getNewsArticles();

      expect(result.data, const [ArticleEntity(title: 'Breaking News!')]);
      expect(result.data!.single, isNot(isA<ArticleModel>()));
    });

    test('returns a failure when the news cannot be loaded', () async {
      final error = Exception('No connection');
      when(() => newsHeadlinesService.getTopHeadlines()).thenThrow(error);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, error);
    });

    test('returns the saved articles as entities', () async {
      when(() => articleDao.getArticles()).thenAnswer((_) async => const [SavedArticleRecord(id: 1, title: 'Saved')]);

      expect(await repository.getSavedArticles(), const [ArticleEntity(id: 1, title: 'Saved')]);
    });

    test('saves and removes articles in the local database', () async {
      const article = ArticleEntity(id: 1, title: 'Saved');
      when(() => articleDao.insertArticle(any())).thenAnswer((_) async {});
      when(() => articleDao.deleteArticle(any())).thenAnswer((_) async {});

      await repository.saveArticle(article);
      await repository.removeArticle(article);

      final inserted = verify(() => articleDao.insertArticle(captureAny())).captured.single as SavedArticleRecord;
      final deleted = verify(() => articleDao.deleteArticle(captureAny())).captured.single as SavedArticleRecord;
      expect(inserted.toModel(), const ArticleModel(id: 1, title: 'Saved'));
      expect(deleted.toModel(), const ArticleModel(id: 1, title: 'Saved'));
    });
  });
}
