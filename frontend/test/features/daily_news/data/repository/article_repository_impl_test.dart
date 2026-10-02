import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_record.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class MockNewsApiService extends Mock implements NewsApiService {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockArticleDao extends Mock implements ArticleDao {}

/// The news from NewsAPI and saving them on the phone (the database of the original app).
void main() {
  late MockNewsApiService newsApiService;
  late MockArticleDao articleDao;
  late ArticleRepositoryImpl repository;

  const article = ArticleEntity(
    title: 'Steelers trade Joey Porter Jr. to the Cowboys',
    url: 'https://example.com/steelers',
    publishedAt: '2026-10-01T03:55:00Z',
  );
  const savedArticle = SavedArticleRecord(
    id: 7,
    title: 'Steelers trade Joey Porter Jr. to the Cowboys',
    url: 'https://example.com/steelers',
    publishedAt: '2026-10-01T03:55:00Z',
  );

  setUpAll(() => registerFallbackValue(const SavedArticleRecord()));

  setUp(() {
    newsApiService = MockNewsApiService();
    articleDao = MockArticleDao();
    final database = MockAppDatabase();
    when(() => database.articleDAO).thenReturn(articleDao);
    repository = ArticleRepositoryImpl(newsApiService, database);
  });

  group('getNewsArticles', () {
    void answerNewsApiWith(Future<List<ArticleModel>> Function(Invocation) answer) {
      when(() => newsApiService.getNewsArticles(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenAnswer(answer);
    }

    test('returns the news as entities, not models', () async {
      answerNewsApiWith((_) async => [ArticleModel.fromEntity(article)]);

      final dataState = await repository.getNewsArticles();

      expect(dataState.data, [article]);
      expect(dataState.data!.single, isNot(isA<ArticleModel>()));
    });

    test('returns a failure when the request fails', () async {
      answerNewsApiWith((_) async => throw Exception('No connection'));

      expect(await repository.getNewsArticles(), isA<DataFailed>());
    });
  });

  group('getSavedArticles', () {
    test('returns the saved articles as entities', () async {
      when(() => articleDao.getArticles()).thenAnswer((_) async => [savedArticle]);

      final dataState = await repository.getSavedArticles();

      expect(dataState.data!.single.id, 7);
      expect(dataState.data!.single, isNot(isA<ArticleModel>()));
    });

    test('returns a failure when the database cannot be read', () async {
      when(() => articleDao.getArticles()).thenThrow(Exception('Database closed'));

      expect(await repository.getSavedArticles(), isA<DataFailed>());
    });
  });

  group('isArticleSaved', () {
    test('is true when an article with the same URL is saved', () async {
      when(() => articleDao.findArticleByUrl(article.url!)).thenAnswer((_) async => savedArticle);

      expect((await repository.isArticleSaved(article)).data, isTrue);
    });

    test('is false when it is not saved', () async {
      when(() => articleDao.findArticleByUrl(article.url!)).thenAnswer((_) async => null);

      expect((await repository.isArticleSaved(article)).data, isFalse);
    });

    test('returns a failure when the database cannot be read', () async {
      when(() => articleDao.findArticleByUrl(article.url!)).thenThrow(Exception('Database closed'));

      expect(await repository.isArticleSaved(article), isA<DataFailed>());
    });
  });

  group('saveArticle', () {
    test('saves an article that is not saved yet', () async {
      when(() => articleDao.findArticleByUrl(article.url!)).thenAnswer((_) async => null);
      when(() => articleDao.insertArticle(any())).thenAnswer((_) async {});

      await repository.saveArticle(article);

      verify(() => articleDao.insertArticle(any())).called(1);
    });

    test('does not save the same article twice', () async {
      when(() => articleDao.findArticleByUrl(article.url!)).thenAnswer((_) async => savedArticle);

      await repository.saveArticle(article);

      verifyNever(() => articleDao.insertArticle(any()));
    });
  });

  test('removes an article by its URL, so it works for an article that comes from NewsAPI', () async {
    when(() => articleDao.deleteArticleByUrl(article.url!)).thenAnswer((_) async {});

    await repository.removeArticle(article);

    verify(() => articleDao.deleteArticleByUrl(article.url!)).called(1);
  });
}
