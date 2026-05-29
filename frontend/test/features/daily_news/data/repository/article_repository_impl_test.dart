import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/news_api_response.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/register_fallback_values.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late ArticleRepositoryImpl repository;
  late MockNewsApiService mockNewsApi;
  late MockAppDatabase mockDatabase;
  late MockArticleDao mockDao;
  late MockFirestoreArticleDataSource mockFirestore;
  late MockFirebaseStorageDataSource mockStorage;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockNewsApi = MockNewsApiService();
    mockDatabase = MockAppDatabase();
    mockDao = MockArticleDao();
    mockFirestore = MockFirestoreArticleDataSource();
    mockStorage = MockFirebaseStorageDataSource();
    mockAuthRepository = MockAuthRepository();

    when(() => mockDatabase.articleDAO).thenReturn(mockDao);

    repository = ArticleRepositoryImpl(
      mockNewsApi,
      mockDatabase,
      mockFirestore,
      mockStorage,
      mockAuthRepository,
    );
  });

  group('getNewsArticles', () {
    test('returns DataSuccess on HTTP 200', () async {
      final models = testArticleModelList();
      when(() => mockNewsApi.getNewsArticles(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => HttpResponse(
            NewsApiResponse(articles: models),
            Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: HttpStatus.ok,
            ),
          ));

      final result = await repository.getNewsArticles();

      expect(result, isA<DataSuccess>());
      expect(result.data!.length, models.length);
    });

    test('returns DataFailed on non-200 status', () async {
      when(() => mockNewsApi.getNewsArticles(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => HttpResponse(
            const NewsApiResponse(articles: []),
            Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 500,
              statusMessage: 'Internal Server Error',
            ),
          ));

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed>());
    });

    test('returns DataFailed on DioError', () async {
      when(() => mockNewsApi.getNewsArticles(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenThrow(DioError(
        type: DioErrorType.connectTimeout,
        requestOptions: RequestOptions(path: ''),
      ));

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed>());
      expect(result.error, isA<NetworkException>());
    });
  });

  group('getSavedArticles', () {
    test('returns mapped entities from DAO', () async {
      final models = testArticleModelList();
      when(() => mockDao.getArticles())
          .thenAnswer((_) async => models);

      final result = await repository.getSavedArticles();

      expect(result, isA<DataSuccess>());
      expect(result.data!.length, models.length);
      expect(result.data!.first.id, models.first.id);
    });
  });

  group('saveArticle', () {
    test('delegates to DAO.insertArticle', () async {
      when(() => mockDao.insertArticle(any()))
          .thenAnswer((_) async {});

      await repository.saveArticle(testArticle());

      verify(() => mockDao.insertArticle(any())).called(1);
    });
  });

  group('removeArticle', () {
    test('delegates to DAO.deleteArticle', () async {
      when(() => mockDao.deleteArticle(any()))
          .thenAnswer((_) async {});

      await repository.removeArticle(testArticle());

      verify(() => mockDao.deleteArticle(any())).called(1);
    });
  });

  group('createArticle', () {
    test('returns DataSuccess on success', () async {
      final model = testArticleModel();
      when(() => mockFirestore.createArticle(any()))
          .thenAnswer((_) async => model);

      final result = await repository.createArticle(testArticle());

      expect(result, isA<DataSuccess>());
      expect(result.data!.id, model.id);
    });

    test('returns DataFailed on FirebaseException', () async {
      when(() => mockFirestore.createArticle(any()))
          .thenThrow(FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
      ));

      final result = await repository.createArticle(testArticle());

      expect(result, isA<DataFailed>());
      expect(result.error, isA<AuthException>());
    });

    test('returns DataFailed on generic exception', () async {
      when(() => mockFirestore.createArticle(any()))
          .thenThrow(Exception('unexpected'));

      final result = await repository.createArticle(testArticle());

      expect(result, isA<DataFailed>());
    });
  });

  group('updateArticle', () {
    test('returns DataSuccess on success', () async {
      final model = testArticleModel(title: 'Updated');
      when(() => mockFirestore.updateArticle(any()))
          .thenAnswer((_) async => model);

      final result = await repository.updateArticle(testArticle());

      expect(result, isA<DataSuccess>());
    });

    test('returns DataFailed on FirebaseException', () async {
      when(() => mockFirestore.updateArticle(any()))
          .thenThrow(FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
      ));

      final result = await repository.updateArticle(testArticle());

      expect(result, isA<DataFailed>());
      expect(result.error, isA<NotFoundException>());
    });
  });

  group('deleteArticle', () {
    test('returns DataSuccess on success', () async {
      when(() => mockFirestore.deleteArticle(any()))
          .thenAnswer((_) async {});

      final result = await repository.deleteArticle(tArticleId);

      expect(result, isA<DataSuccess>());
    });

    test('returns DataFailed on FirebaseException', () async {
      when(() => mockFirestore.deleteArticle(any()))
          .thenThrow(FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
      ));

      final result = await repository.deleteArticle(tArticleId);

      expect(result, isA<DataFailed>());
    });
  });

  group('getPublishedArticles', () {
    test('stream maps models to DataSuccess with entities', () async {
      final models = testArticleModelList();
      when(() => mockFirestore.getPublishedArticles())
          .thenAnswer((_) => Stream.value(models));

      final stream = repository.getPublishedArticles();
      final result = await stream.first;

      expect(result, isA<DataSuccess>());
      expect(result.data!.length, models.length);
      expect(result.data!.first.id, models.first.id);
      verify(() => mockFirestore.getPublishedArticles()).called(1);
    });

    test('stream emits DataFailed when source stream errors', () async {
      when(() => mockFirestore.getPublishedArticles())
          .thenAnswer((_) => Stream.error(Exception('stream error')));

      final stream = repository.getPublishedArticles();
      final result = await stream.first;

      expect(result, isA<DataFailed>());
    });
  });

  group('getUserArticles', () {
    test('stream maps models to DataSuccess with entities', () async {
      final models = testArticleModelList();
      when(() => mockFirestore.getUserArticles(any()))
          .thenAnswer((_) => Stream.value(models));

      final stream = repository.getUserArticles(tUserId);
      final result = await stream.first;

      expect(result, isA<DataSuccess>());
      expect(result.data!.length, models.length);
      verify(() => mockFirestore.getUserArticles(tUserId)).called(1);
    });

    test('stream emits DataFailed when source stream errors', () async {
      when(() => mockFirestore.getUserArticles(any()))
          .thenAnswer((_) => Stream.error(Exception('fail')));

      final stream = repository.getUserArticles(tUserId);
      final result = await stream.first;

      expect(result, isA<DataFailed>());
    });
  });

  group('getDraftArticles', () {
    test('stream maps models to DataSuccess with entities', () async {
      final models = testArticleModelList();
      when(() => mockFirestore.getDraftArticles(any()))
          .thenAnswer((_) => Stream.value(models));

      final stream = repository.getDraftArticles(tUserId);
      final result = await stream.first;

      expect(result, isA<DataSuccess>());
      expect(result.data!.length, models.length);
      verify(() => mockFirestore.getDraftArticles(tUserId)).called(1);
    });

    test('stream emits DataFailed when source stream errors', () async {
      when(() => mockFirestore.getDraftArticles(any()))
          .thenAnswer((_) => Stream.error(Exception('fail')));

      final stream = repository.getDraftArticles(tUserId);
      final result = await stream.first;

      expect(result, isA<DataFailed>());
    });
  });

  group('uploadThumbnail', () {
    test('returns DataSuccess with download URL', () async {
      when(() => mockAuthRepository.currentUser)
          .thenReturn(testAuthUser(uid: tUserId));
      when(() => mockStorage.uploadThumbnail(
            uid: any(named: 'uid'),
            articleId: any(named: 'articleId'),
            filePath: any(named: 'filePath'),
          )).thenAnswer((_) async => tThumbnailUrl);

      final result = await repository.uploadThumbnail(
        articleId: tArticleId,
        filePath: tFilePath,
      );

      expect(result, isA<DataSuccess>());
      expect(result.data, tThumbnailUrl);
    });

    test('returns DataFailed when user is not authenticated', () async {
      when(() => mockAuthRepository.currentUser).thenReturn(null);

      final result = await repository.uploadThumbnail(
        articleId: tArticleId,
        filePath: tFilePath,
      );

      expect(result, isA<DataFailed>());
      expect(result.error, isA<AuthException>());
    });

    test('returns DataFailed on FirebaseException', () async {
      when(() => mockAuthRepository.currentUser)
          .thenReturn(testAuthUser(uid: tUserId));
      when(() => mockStorage.uploadThumbnail(
            uid: any(named: 'uid'),
            articleId: any(named: 'articleId'),
            filePath: any(named: 'filePath'),
          )).thenThrow(FirebaseException(
        plugin: 'storage',
        code: 'unauthorized',
      ));

      final result = await repository.uploadThumbnail(
        articleId: tArticleId,
        filePath: tFilePath,
      );

      expect(result, isA<DataFailed>());
      expect(result.error, isA<StorageException>());
    });
  });
}
