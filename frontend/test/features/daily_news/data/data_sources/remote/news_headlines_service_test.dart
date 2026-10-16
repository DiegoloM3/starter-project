import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_headlines_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:retrofit/retrofit.dart';

class MockNewsApiService extends Mock implements NewsApiService {}

void main() {
  late MockNewsApiService newsApiService;
  late NewsHeadlinesService service;

  const articles = [ArticleModel(title: 'Breaking News!')];

  setUp(() {
    newsApiService = MockNewsApiService();
    service = NewsHeadlinesService(newsApiService);
  });

  void stubResponse(int statusCode) {
    final response = Response<dynamic>(requestOptions: RequestOptions(path: '/top-headlines'), statusCode: statusCode);
    when(() => newsApiService.getNewsArticles(
          apiKey: any(named: 'apiKey'),
          country: any(named: 'country'),
          category: any(named: 'category'),
        )).thenAnswer((_) async => HttpResponse(articles, response));
  }

  group('NewsHeadlinesService', () {
    test('returns the articles of a successful response', () async {
      stubResponse(200);

      expect(await service.getTopHeadlines(), articles);
    });

    test('throws when the news API does not answer successfully', () async {
      stubResponse(500);

      expect(service.getTopHeadlines(), throwsA(isA<DioError>()));
    });
  });
}
