import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:retrofit/dio.dart';

class _MockNewsApiService extends Mock implements NewsApiService {}

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockArticleDao extends Mock implements ArticleDao {}

Response<dynamic> _response(int statusCode, {String? message}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: '/top-headlines'),
    statusCode: statusCode,
    statusMessage: message,
  );
}

void main() {
  late _MockNewsApiService api;
  late _MockAppDatabase db;
  late _MockArticleDao dao;
  late ArticleRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const ArticleModel());
  });

  setUp(() {
    api = _MockNewsApiService();
    db = _MockAppDatabase();
    dao = _MockArticleDao();
    when(() => db.articleDAO).thenReturn(dao);
    repository = ArticleRepositoryImpl(api, db);
  });

  group('getNewsArticles', () {
    test('returns entities mapped from models on 200', () async {
      const model = ArticleModel(id: 1, title: 't', urlToImage: '');
      when(
        () => api.getNewsArticles(
          apiKey: any(named: 'apiKey'),
          country: any(named: 'country'),
          category: any(named: 'category'),
        ),
      ).thenAnswer(
        (_) async => HttpResponse([model], _response(HttpStatus.ok)),
      );

      final result = await repository.getNewsArticles();

      expect(result.isRight(), isTrue);
      final entities = result.getOrElse(() => const <ArticleEntity>[]);
      expect(entities.single.id, 1);
      expect(entities.single.title, 't');
    });

    test('returns NetworkFailure carrying the status when not 200', () async {
      when(
        () => api.getNewsArticles(
          apiKey: any(named: 'apiKey'),
          country: any(named: 'country'),
          category: any(named: 'category'),
        ),
      ).thenAnswer(
        (_) async => HttpResponse(
          const <ArticleModel>[],
          _response(HttpStatus.internalServerError, message: 'Boom'),
        ),
      );

      final result = await repository.getNewsArticles();

      expect(
        result,
        const Left<AppFailure, List<ArticleEntity>>(
          AppFailure.network(
            message: 'Boom',
            statusCode: HttpStatus.internalServerError,
          ),
        ),
      );
    });

    test('wraps thrown Exception into NetworkFailure', () async {
      when(
        () => api.getNewsArticles(
          apiKey: any(named: 'apiKey'),
          country: any(named: 'country'),
          category: any(named: 'category'),
        ),
      ).thenThrow(Exception('socket'));

      final result = await repository.getNewsArticles();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected failure'),
      );
    });
  });

  group('local cache', () {
    test('getSavedArticles maps DAO models to entities', () async {
      when(dao.getArticles)
          .thenAnswer((_) async => const [ArticleModel(id: 7, title: 'saved')]);

      final result = await repository.getSavedArticles();

      expect(result.isRight(), isTrue);
      final entities = result.getOrElse(() => const <ArticleEntity>[]);
      expect(entities.single.id, 7);
    });

    test('saveArticle converts entity to model and returns Unit', () async {
      when(() => dao.insertArticle(any())).thenAnswer((_) async {});

      final result = await repository.saveArticle(
        const ArticleEntity(id: 9, title: 'x'),
      );

      expect(result, const Right<AppFailure, Unit>(unit));
      verify(() => dao.insertArticle(any())).called(1);
    });

    test('removeArticle maps DAO exception to CacheFailure', () async {
      when(() => dao.deleteArticle(any())).thenThrow(Exception('disk full'));

      final result = await repository.removeArticle(
        const ArticleEntity(id: 9),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<CacheFailure>()),
        (_) => fail('expected cache failure'),
      );
    });
  });
}
