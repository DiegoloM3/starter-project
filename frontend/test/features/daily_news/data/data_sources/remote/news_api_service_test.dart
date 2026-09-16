import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late NewsApiService service;

  final requestOptions = RequestOptions(path: '/');

  Response<Map<String, dynamic>> responseWith(Map<String, dynamic>? body) {
    return Response(data: body, statusCode: 200, requestOptions: requestOptions);
  }

  When<Future<Response<Map<String, dynamic>>>> whenGet() {
    return when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    );
  }

  List<dynamic> capturedGet() {
    return verify(
      () => dio.get<Map<String, dynamic>>(
        captureAny(),
        queryParameters: captureAny(named: 'queryParameters'),
      ),
    ).captured;
  }

  setUp(() {
    dio = MockDio();
    service = NewsApiService(dio);
  });

  group('getTopHeadlines', () {
    test('calls /top-headlines with the fixed country, the category and the API key', () async {
      whenGet().thenAnswer((_) async => responseWith({'articles': []}));

      await service.getTopHeadlines(category: 'science');

      final captured = capturedGet();
      expect(captured[0], '$newsAPIBaseURL/top-headlines');
      expect(captured[1], {
        'apiKey': newsAPIKey,
        'country': 'us',
        'category': 'science',
      });
    });

    test('maps every JSON object in "articles" to a model', () async {
      whenGet().thenAnswer(
        (_) async => responseWith({
          'articles': [
            {'title': 'First', 'url': 'https://a.example/1'},
            {'title': 'Second', 'url': 'https://a.example/2'},
          ],
        }),
      );

      final articles = await service.getTopHeadlines(category: 'general');

      expect(articles.map((a) => a.title), ['First', 'Second']);
    });

    test('returns an empty list when "articles" is missing or not a list', () async {
      whenGet().thenAnswer((_) async => responseWith({'status': 'ok', 'articles': 'x'}));
      expect(await service.getTopHeadlines(category: 'general'), isEmpty);

      whenGet().thenAnswer((_) async => responseWith(null));
      expect(await service.getTopHeadlines(category: 'general'), isEmpty);
    });

    test('skips entries that are not JSON objects', () async {
      whenGet().thenAnswer(
        (_) async => responseWith({'articles': [1, 'x', {'title': 'Only'}]}),
      );

      final articles = await service.getTopHeadlines(category: 'general');

      expect(articles.single.title, 'Only');
    });

    test('lets DioException propagate', () {
      final failure = DioException(requestOptions: requestOptions);
      whenGet().thenThrow(failure);

      expect(
        service.getTopHeadlines(category: 'general'),
        throwsA(same(failure)),
      );
    });
  });

  group('searchArticles', () {
    test('calls /everything with the query sorted by date', () async {
      whenGet().thenAnswer((_) async => responseWith({'articles': []}));

      await service.searchArticles('bike lanes');

      final captured = capturedGet();
      expect(captured[0], '$newsAPIBaseURL/everything');
      final query = captured[1] as Map<String, dynamic>;
      expect(query['q'], 'bike lanes');
      expect(query['sortBy'], 'publishedAt');
      expect(query['apiKey'], newsAPIKey);
      expect(query['pageSize'], isA<int>());
    });
  });
}
