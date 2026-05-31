import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_client.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/models/top_headlines.dart';
import 'package:retrofit/retrofit.dart';

import 'news_api_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NewsApiClient>()])
void main() {
  group('NewsApiService', () {
    late MockNewsApiClient client;
    late NewsApiService service;

    setUp(() {
      client = MockNewsApiClient();
      service = NewsApiService(client);
    });

    test(
      'forwards request parameters and returns paginated headlines',
      () async {
        final mockModel = TopHeadlinesModel.fromJson({
          'status': 'ok',
          'totalResults': 2,
          'articles': [
            {
              'title': 'Top headline',
              'source': {},
              'author': null,
              'description': null,
              'url': '',
              'urlToImage': null,
              'publishedAt': '',
              'content': null,
            },
          ],
        });
        final mockDioResponse = Response(
          requestOptions: RequestOptions(path: '/top-headlines'),
          statusCode: 200,
        );

        when(
          client.getNewsArticles(
            apiKey: anyNamed('apiKey'),
            country: anyNamed('country'),
            category: anyNamed('category'),
            page: anyNamed('page'),
            pageSize: anyNamed('pageSize'),
            cancelToken: anyNamed('cancelToken'),
          ),
        ).thenAnswer((_) async => HttpResponse(mockModel, mockDioResponse));

        final cancellable = service.getNewsArticles(
          apiKey: 'api-key',
          country: 'us',
          category: 'business',
          page: 1,
          pageSize: 20,
        );

        final result = await cancellable.call;
        expect(result.data.total, 2);
        expect(result.data.results.length, 1);

        final verification = verify(
          client.getNewsArticles(
            apiKey: 'api-key',
            country: 'us',
            category: 'business',
            page: 1,
            pageSize: 20,
            cancelToken: captureAnyNamed('cancelToken'),
          ),
        );
        final capturedToken = verification.captured.single as CancelToken;

        expect(capturedToken, same(cancellable.token));
        expect(cancellable.token.isCancelled, isFalse);
      },
    );

    test('cancels the same token passed to the client', () async {
      final completer = Completer<HttpResponse<TopHeadlinesModel>>();
      when(
        client.getNewsArticles(
          apiKey: anyNamed('apiKey'),
          country: anyNamed('country'),
          category: anyNamed('category'),
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) => completer.future);

      final cancellable = service.getNewsArticles();
      final verification = verify(
        client.getNewsArticles(
          apiKey: null,
          country: null,
          category: null,
          page: null,
          pageSize: null,
          cancelToken: captureAnyNamed('cancelToken'),
        ),
      );
      final capturedToken = verification.captured.single as CancelToken;

      expect(capturedToken.isCancelled, isFalse);

      cancellable.cancel();

      expect(capturedToken.isCancelled, isTrue);

      final emptyModel = TopHeadlinesModel.fromJson({
        'status': 'ok',
        'totalResults': 0,
        'articles': [],
      });
      final completionResponse = Response(
        requestOptions: RequestOptions(path: '/top-headlines'),
        statusCode: 200,
      );
      completer.complete(HttpResponse(emptyModel, completionResponse));
      final result = await cancellable.call;
      expect(result.data.total, 0);
    });
  });
}
