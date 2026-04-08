import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class _MockNewsApiService extends Mock implements NewsApiService {}

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockArticleDao extends Mock implements ArticleDao {}

void main() {
  late _MockNewsApiService newsApiService;
  late _MockAppDatabase appDatabase;
  late _MockArticleDao articleDao;
  late ArticleRepositoryImpl repository;

  setUp(() {
    newsApiService = _MockNewsApiService();
    appDatabase = _MockAppDatabase();
    articleDao = _MockArticleDao();
    when(() => appDatabase.articleDAO).thenReturn(articleDao);
    repository = ArticleRepositoryImpl(newsApiService, appDatabase);
  });

  setUpAll(() {
    registerFallbackValue(const ArticleModel());
  });

  test('getSavedArticles delegates to DAO', () async {
    const saved = <ArticleModel>[ArticleModel(title: 'saved')];
    when(() => articleDao.getArticles()).thenAnswer((_) async => saved);

    final result = await repository.getSavedArticles();

    expect(result, saved);
    verify(() => articleDao.getArticles()).called(1);
  });

  test('saveArticle delegates to DAO insert', () async {
    const article = ArticleEntity(title: 'new');
    when(() => articleDao.insertArticle(any())).thenAnswer((_) async {});

    await repository.saveArticle(article);

    verify(() => articleDao.insertArticle(any())).called(1);
  });

  test('removeArticle delegates to DAO delete', () async {
    const article = ArticleEntity(title: 'old');
    when(() => articleDao.deleteArticle(any())).thenAnswer((_) async {});

    await repository.removeArticle(article);

    verify(() => articleDao.deleteArticle(any())).called(1);
  });
}
