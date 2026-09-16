import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/news_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';

class MockNewsApiService extends Mock implements NewsApiService {}

void main() {
  late MockNewsApiService api;
  late NewsRepositoryImpl repository;

  final model = ArticleModel.fromRawData(const {
    'title': 'Headline',
    'url': 'https://news.example/1',
    'publishedAt': '2026-09-15T10:00:00Z',
  });

  DioException dioError(DioExceptionType type, {int? status}) {
    final options = RequestOptions(path: '/');
    return DioException(
      requestOptions: options,
      type: type,
      response: status == null ? null : Response(requestOptions: options, statusCode: status),
    );
  }

  setUp(() {
    api = MockNewsApiService();
    repository = NewsRepositoryImpl(api);
  });

  group('getTopHeadlines', () {
    test('forwards the category api value to the service', () async {
      when(() => api.getTopHeadlines(category: 'sports'))
          .thenAnswer((_) async => [model]);

      final result = await repository.getTopHeadlines(
        const NewsQuery(category: NewsCategory.sports),
      );

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.dataOrNull!.single.title, 'Headline');
      expect(result.dataOrNull!.single, isNot(isA<ArticleModel>()));
    });

    test('maps a connection timeout to a network failure', () async {
      when(() => api.getTopHeadlines(category: any(named: 'category')))
          .thenThrow(dioError(DioExceptionType.connectionTimeout));

      final result = await repository.getTopHeadlines(const NewsQuery());

      expect(result.failureOrNull?.type, FailureType.network);
    });

    test('maps HTTP 401 to a permission failure', () async {
      when(() => api.getTopHeadlines(category: any(named: 'category')))
          .thenThrow(dioError(DioExceptionType.badResponse, status: 401));

      final result = await repository.getTopHeadlines(const NewsQuery());

      expect(result.failureOrNull?.type, FailureType.permissionDenied);
    });

    test('maps HTTP 429 to a server failure', () async {
      when(() => api.getTopHeadlines(category: any(named: 'category')))
          .thenThrow(dioError(DioExceptionType.badResponse, status: 429));

      final result = await repository.getTopHeadlines(const NewsQuery());

      expect(result.failureOrNull?.type, FailureType.server);
    });

    test('maps a cancelled request to a cancelled failure', () async {
      when(() => api.getTopHeadlines(category: any(named: 'category')))
          .thenThrow(dioError(DioExceptionType.cancel));

      final result = await repository.getTopHeadlines(const NewsQuery());

      expect(result.failureOrNull?.type, FailureType.cancelled);
    });

    test('an error that is not from the transport is still a failure, never a throw', () async {
      when(() => api.getTopHeadlines(category: any(named: 'category')))
          .thenThrow(StateError('bug'));

      final result = await repository.getTopHeadlines(const NewsQuery());

      expect(result.failureOrNull?.type, FailureType.unknown);
    });
  });

  group('searchArticles', () {
    test('returns entities on success', () async {
      when(() => api.searchArticles('bikes')).thenAnswer((_) async => [model]);

      final result = await repository.searchArticles('bikes');

      expect(result.dataOrNull, hasLength(1));
    });

    test('maps HTTP 404 to a not-found failure', () async {
      when(() => api.searchArticles(any()))
          .thenThrow(dioError(DioExceptionType.badResponse, status: 404));

      final result = await repository.searchArticles('bikes');

      expect(result.failureOrNull?.type, FailureType.notFound);
    });
  });
}
