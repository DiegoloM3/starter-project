import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/article_local_mapper.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/news/data/models/news_api_response.dart';
import 'package:news_app_clean_architecture/features/news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:retrofit/retrofit.dart';

import 'article_repository_impl_test.mocks.dart';

@GenerateMocks([NewsApiService, AppDatabase, ArticleDao])
void main() {
  late MockNewsApiService mockApiService;
  late MockAppDatabase mockAppDatabase;
  late MockArticleDao mockArticleDao;
  late ArticleRepositoryImpl repository;

  // Drift-generated ArticlesTableData row fixture
  final tArticleRow = ArticlesTableData(
    id: "1",
    authorDisplayName: 'John Doe',
    title: 'Test Title',
    urlToImage: 'https://example.com/image.jpg',
    publishedAt: '2024-01-01T00:00:00Z',
    content: 'Test Content',
    authorId: null,
  );
  final tArticleRows = [tArticleRow];

  // ArticleModel equivalent (what the repository returns after mapping)
  final tArticleModel = ArticleLocalMapper.fromRow(tArticleRow);
  final tArticleModelList = [tArticleModel];

  const tArticleEntity = ArticleEntity(
    id: "1",
    authorDisplayName: 'John Doe',
    title: 'Test Title',
    urlToImage: 'https://example.com/image.jpg',
    publishedAt: '2024-01-01T00:00:00Z',
    content: 'Test Content',
  );

  setUp(() {
    mockApiService = MockNewsApiService();
    mockAppDatabase = MockAppDatabase();
    mockArticleDao = MockArticleDao();

    // Wire up database mock so articleDao getter returns the DAO mock
    when(mockAppDatabase.articleDao).thenReturn(mockArticleDao);

    repository = ArticleRepositoryImpl(mockApiService, mockAppDatabase);
  });

  // ---------------------------------------------------------------------------
  group('getNewsArticles', () {
    test('should return DataSuccess with article list on HTTP 200', () async {
      final requestOptions = RequestOptions(path: '/top-headlines');
      final apiResponse = NewsApiResponse(status: 'ok', articles: tArticleModelList);
      final response = Response<NewsApiResponse>(
        data: apiResponse,
        statusCode: HttpStatus.ok,
        requestOptions: requestOptions,
      );
      final httpResponse = HttpResponse(apiResponse, response);

      when(mockApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      )).thenAnswer((_) async => httpResponse);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data!.length, tArticleModelList.length);
      expect(result.data!.first.title, tArticleModelList.first.title);
    });

    test('should return DataFailed on non-200 HTTP status', () async {
      final requestOptions = RequestOptions(path: '/top-headlines');
      final apiResponse = NewsApiResponse(status: 'error', articles: []);
      final response = Response<NewsApiResponse>(
        data: null,
        statusCode: HttpStatus.unauthorized,
        statusMessage: 'Unauthorized',
        requestOptions: requestOptions,
      );
      final httpResponse = HttpResponse<NewsApiResponse>(apiResponse, response);

      when(mockApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      )).thenAnswer((_) async => httpResponse);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataDioFailed<List<ArticleEntity>>>());
      expect(result.error?.type, DioExceptionType.badResponse);
    });

    test('assigns local ids to API articles missing one', () async {
      final requestOptions = RequestOptions(path: '/top-headlines');
      const idLess = ArticleModel(
        authorDisplayName: 'John Doe',
        title: 'No ID Title',
        publishedAt: '2024-01-01T00:00:00Z',
        content: 'No ID Content',
      );
      const withId = ArticleModel(
        id: 'keep-me',
        authorDisplayName: 'Jane',
        title: 'Has ID',
        publishedAt: '2024-01-02T00:00:00Z',
        content: 'Has ID Content',
      );
      final apiResponse = NewsApiResponse(
        status: 'ok',
        articles: const [idLess, withId],
      );
      final response = Response<NewsApiResponse>(
        data: apiResponse,
        statusCode: HttpStatus.ok,
        requestOptions: requestOptions,
      );
      final httpResponse = HttpResponse(apiResponse, response);

      when(mockApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      )).thenAnswer((_) async => httpResponse);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      final ids = result.data!.map((e) => e.id).toList();
      expect(ids.every((id) => id != null && id!.isNotEmpty), isTrue);
      expect(ids.toSet().length, ids.length);
      expect(
        result.data!.firstWhere((e) => e.title == 'Has ID').id,
        'keep-me',
      );
    });

    test('should return DataFailed when a DioException is thrown', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioExceptionType.connectionTimeout,
      );

      when(mockApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      )).thenThrow(dioException);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataDioFailed<List<ArticleEntity>>>());
      expect(result.error, dioException);
    });
  });

  // ---------------------------------------------------------------------------
  group('getSavedArticles', () {
    test('should return mapped articles from the local database', () async {
      when(mockArticleDao.getArticles()).thenAnswer((_) async => tArticleRows);

      final result = await repository.getSavedArticles();

      expect(result.length, 1);
      expect(result.first.id, tArticleRow.id);
      expect(result.first.title, tArticleRow.title);
      verify(mockArticleDao.getArticles()).called(1);
    });

    test('should return empty list when no articles are saved', () async {
      when(mockArticleDao.getArticles()).thenAnswer((_) async => []);

      final result = await repository.getSavedArticles();

      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  group('saveArticle', () {
    test('should call insertArticle on the DAO with an ArticlesCompanion',
        () async {
      when(mockArticleDao.getArticles()).thenAnswer((_) async => []);
      when(mockArticleDao.insertArticle(any)).thenAnswer((_) async {});

      await repository.saveArticle(tArticleEntity);

      final captured =
          verify(mockArticleDao.insertArticle(captureAny)).captured.single
              as ArticlesTableCompanion;
      expect(captured.id, const Value('1'));
      expect(captured.title, const Value('Test Title'));
    });

    test('should skip insert when the same article is already saved',
        () async {
      when(mockArticleDao.getArticles())
          .thenAnswer((_) async => tArticleRows);

      await repository.saveArticle(tArticleEntity);

      verifyNever(mockArticleDao.insertArticle(any));
    });

    test(
        'should skip insert for a re-fetched API article with a fresh '
        'local id but the same title and date', () async {
      final savedRow = ArticlesTableData(
        id: 'local-111',
        authorDisplayName: 'John Doe',
        title: 'Daily Title',
        urlToImage: 'https://example.com/image.jpg',
        publishedAt: '2024-01-01T00:00:00Z',
        content: 'Daily Content',
        authorId: null,
      );
      const refetched = ArticleEntity(
        id: 'local-222',
        authorDisplayName: 'John Doe',
        title: 'Daily Title',
        urlToImage: 'https://example.com/image.jpg',
        publishedAt: '2024-01-01T00:00:00Z',
        content: 'Daily Content',
      );
      when(mockArticleDao.getArticles())
          .thenAnswer((_) async => [savedRow]);
      when(mockArticleDao.insertArticle(any)).thenAnswer((_) async {});

      await repository.saveArticle(refetched);

      verifyNever(mockArticleDao.insertArticle(any));
    });
  });

  // ---------------------------------------------------------------------------
  group('removeArticle', () {
    test('should call deleteArticle on the DAO after finding the matching row',
        () async {
      when(mockArticleDao.getArticles()).thenAnswer((_) async => tArticleRows);
      when(mockArticleDao.deleteArticle(any)).thenAnswer((_) async {});

      await repository.removeArticle(tArticleEntity);

      final captured =
          verify(mockArticleDao.deleteArticle(captureAny)).captured.single
              as ArticlesTableData;
      expect(captured.id, tArticleEntity.id);
    });

    test('should throw when the article is not found in the database', () async {
      when(mockArticleDao.getArticles()).thenAnswer((_) async => []);

      expect(
        () => repository.removeArticle(tArticleEntity),
        throwsException,
      );
    });

    test(
        'removes the null-id article matching title and date without '
        'throwing (regression: daily delete crash)', () async {
      final nullIdRow = ArticlesTableData(
        authorDisplayName: 'John Doe',
        title: 'Daily Null',
        urlToImage: 'https://example.com/image.jpg',
        publishedAt: '2024-01-01T00:00:00Z',
        content: 'Daily Content',
        authorId: null,
      );
      const nullIdEntity = ArticleEntity(
        authorDisplayName: 'John Doe',
        title: 'Daily Null',
        urlToImage: 'https://example.com/image.jpg',
        publishedAt: '2024-01-01T00:00:00Z',
        content: 'Daily Content',
      );
      when(mockArticleDao.getArticles())
          .thenAnswer((_) async => [nullIdRow, tArticleRow]);
      when(mockArticleDao.deleteArticle(any)).thenAnswer((_) async {});

      await repository.removeArticle(nullIdEntity);

      final captured =
          verify(mockArticleDao.deleteArticle(captureAny)).captured.single
              as ArticlesTableData;
      expect(captured.title, 'Daily Null');
      expect(captured.id, isNull);
    });
  });
}
