import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_service.dart.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/page.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:sqflite/sqflite.dart';

class MockNewsService extends Mock implements NewsService {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockArticleDao extends Mock implements ArticleDao {}

class MockDatabaseException extends Mock implements DatabaseException {
  @override
  bool isDatabaseClosedError() => false;
  @override
  bool isReadOnlyError() => false;
  @override
  bool isNoSuchTableError([String? table]) => false;
  @override
  bool isSyntaxError() => false;
  @override
  bool isOpenFailedError() => false;
  @override
  bool isUniqueConstraintError([String? field]) => false;
  @override
  bool isNotNullConstraintError([String? field]) => false;
  @override
  bool isDuplicateColumnError([String? field]) => false;
}

class FakeFile extends Fake implements File {}

void main() {
  late ArticleRepositoryImpl articleRepositoryImpl;
  late MockNewsService mockNewsService;
  late MockAppDatabase mockAppDatabase;
  late MockArticleDao mockArticleDao;

  setUp(() {
    mockNewsService = MockNewsService();
    mockAppDatabase = MockAppDatabase();
    mockArticleDao = MockArticleDao();
    articleRepositoryImpl =
        ArticleRepositoryImpl(mockNewsService, mockAppDatabase);

    when(() => mockAppDatabase.articleDAO).thenReturn(mockArticleDao);
  });

  const tArticleModel = ArticleModel(
    id: '1',
    author: 'author',
    title: 'title',
    description: 'description',
    url: 'url',
    publishedAt: 'publishedAt',
    content: 'content',
  );

  final tArticleEntity = tArticleModel.toEntity();

  group('getNewsArticles', () {
    const tPage = 1;
    const tSize = 10;
    const tPageModel = PageModel<ArticleModel>(
      content: [tArticleModel],
      page: 1,
      totalPages: 1,
      total: 1,
    );

    test(
        'should return DataSuccess when the call to remote data source is successful',
        () async {
      when(() => mockNewsService.getNewsArticles(
            page: any(named: 'page'),
            size: any(named: 'size'),
            total: any(named: 'total'),
          )).thenAnswer((_) async => tPageModel);

      final result =
          await articleRepositoryImpl.getNewsArticles(page: tPage, size: tSize);

      expect(result, isA<DataSuccess>());
      expect(result.data?.content, isNotEmpty);
      expect(result.data?.content.first, equals(tArticleEntity));
      verify(() => mockNewsService.getNewsArticles(page: tPage, size: tSize))
          .called(1);
    });

    test(
        'should return DataFailed when the call to remote data source is unsuccessful',
        () async {
      final tException = Exception('Something went wrong');
      when(() => mockNewsService.getNewsArticles(
            page: any(named: 'page'),
            size: any(named: 'size'),
            total: any(named: 'total'),
          )).thenThrow(tException);

      final result =
          await articleRepositoryImpl.getNewsArticles(page: tPage, size: tSize);

      expect(result, isA<DataFailed>());
      verify(() => mockNewsService.getNewsArticles(page: tPage, size: tSize))
          .called(1);
    });
  });

  group('getSavedArticles', () {
    test(
        'should return DataSuccess when the call to local data source is successful',
        () async {
      when(() => mockArticleDao.getArticles())
          .thenAnswer((_) async => [tArticleModel]);

      final result = await articleRepositoryImpl.getSavedArticles();

      expect(result, isA<DataSuccess>());
      expect(result.data, equals([tArticleModel]));
      verify(() => mockArticleDao.getArticles()).called(1);
    });

    test(
        'should return DataFailed when the call to local data source is unsuccessful (DatabaseException)',
        () async {
      final tException = MockDatabaseException();
      when(() => mockArticleDao.getArticles()).thenThrow(tException);

      final result = await articleRepositoryImpl.getSavedArticles();

      expect(result, isA<DataFailed>());
      verify(() => mockArticleDao.getArticles()).called(1);
    });
  });

  group('saveArticle', () {
    setUpAll(() {
      registerFallbackValue(tArticleModel);
      registerFallbackValue(FakeFile());
    });

    test('should return DataSuccess when saving article is successful',
        () async {
      when(() => mockArticleDao.insertArticle(any()))
          .thenAnswer((_) async => {});

      final result = await articleRepositoryImpl.saveArticle(tArticleEntity);

      expect(result, isA<DataSuccess>());
      verify(() => mockArticleDao.insertArticle(any())).called(1);
    });

    test('should return DataFailed when saving article is unsuccessful',
        () async {
      when(() => mockArticleDao.insertArticle(any())).thenThrow(Exception());

      final result = await articleRepositoryImpl.saveArticle(tArticleEntity);

      expect(result, isA<DataFailed>());
    });
  });

  group('removeArticle', () {
    setUpAll(() {
      registerFallbackValue(tArticleModel);
    });

    test('should return DataSuccess when removing article is successful',
        () async {
      when(() => mockArticleDao.deleteArticle(any()))
          .thenAnswer((_) async => {});

      final result = await articleRepositoryImpl.removeArticle(tArticleEntity);

      expect(result, isA<DataSuccess>());
      verify(() => mockArticleDao.deleteArticle(any())).called(1);
    });

    test('should return DataFailed when removing article is unsuccessful',
        () async {
      when(() => mockArticleDao.deleteArticle(any())).thenThrow(Exception());

      final result = await articleRepositoryImpl.removeArticle(tArticleEntity);

      expect(result, isA<DataFailed>());
    });
  });

  group('getSavedArticle', () {
    test('should return DataSuccess with article when it exists in database',
        () async {
      when(() => mockArticleDao.getArticleById(any()))
          .thenAnswer((_) async => tArticleModel);

      final result = await articleRepositoryImpl.getSavedArticle('1');

      expect(result, isA<DataSuccess>());
      expect(result.data, equals(tArticleEntity));
      verify(() => mockArticleDao.getArticleById('1')).called(1);
    });

    test(
        'should return DataSuccess with null when it does not exist in database',
        () async {
      when(() => mockArticleDao.getArticleById(any()))
          .thenAnswer((_) async => null);

      final result = await articleRepositoryImpl.getSavedArticle('1');

      expect(result, isA<DataSuccess>());
      expect(result.data, isNull);
    });

    test('should return DataFailed when there is a DatabaseException',
        () async {
      when(() => mockArticleDao.getArticleById(any()))
          .thenThrow(MockDatabaseException());

      final result = await articleRepositoryImpl.getSavedArticle('1');

      expect(result, isA<DataFailed>());
    });
  });

  group('createArticle', () {
    final tFile = File('test_path');
    const tImageUrl = 'http://example.com/image.jpg';

    setUpAll(() {
      registerFallbackValue(tArticleModel);
    });

    test('should return DataSuccess when creating article is successful',
        () async {
      when(() => mockNewsService.uploadImage(any()))
          .thenAnswer((_) async => tImageUrl);
      when(() => mockNewsService.saveArticle(any()))
          .thenAnswer((_) async => {});

      final result = await articleRepositoryImpl.createArticle(
        article: tArticleEntity,
        image: tFile,
      );

      expect(result, isA<DataSuccess>());
      verify(() => mockNewsService.uploadImage(tFile)).called(1);
      verify(() => mockNewsService.saveArticle(any())).called(1);
    });

    test('should return DataFailed when uploading image fails', () async {
      when(() => mockNewsService.uploadImage(any())).thenThrow(Exception());

      final result = await articleRepositoryImpl.createArticle(
        article: tArticleEntity,
        image: tFile,
      );

      expect(result, isA<DataFailed>());
      verify(() => mockNewsService.uploadImage(tFile)).called(1);
      verifyNever(() => mockNewsService.saveArticle(any()));
    });

    test('should return DataFailed when saving article fails', () async {
      when(() => mockNewsService.uploadImage(any()))
          .thenAnswer((_) async => tImageUrl);
      when(() => mockNewsService.saveArticle(any())).thenThrow(Exception());

      final result = await articleRepositoryImpl.createArticle(
        article: tArticleEntity,
        image: tFile,
      );

      expect(result, isA<DataFailed>());
      verify(() => mockNewsService.uploadImage(tFile)).called(1);
      verify(() => mockNewsService.saveArticle(any())).called(1);
    });
  });
}
