import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/news_api_response.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class _FakeRemoteDataSource implements NewsArticlesDataSource {
  @override
  Future<List<ArticleModel>> getNewsArticles() async => const [
        ArticleModel(
          id: 7,
          author: 'Author',
          title: 'Envelope article',
          description: 'Description',
          url: 'https://example.test/article',
          urlToImage: 'https://example.test/image.jpg',
          publishedAt: '2026-09-22T10:00:00Z',
          content: 'Content',
        ),
      ];
}

class _FakeNewsApiService implements NewsApiService {
  final HttpResponse<NewsApiResponseModel> response;
  int calls = 0;
  String? lastApiKey;

  _FakeNewsApiService(this.response);

  @override
  Future<HttpResponse<NewsApiResponseModel>> getNewsArticles({
    String? apiKey,
    String? country,
    String? category,
  }) async {
    calls++;
    lastApiKey = apiKey;
    return response;
  }
}

class _ThrowingNewsApiService implements NewsApiService {
  final DioException error;

  const _ThrowingNewsApiService(this.error);

  @override
  Future<HttpResponse<NewsApiResponseModel>> getNewsArticles({
    String? apiKey,
    String? country,
    String? category,
  }) async =>
      throw error;
}

class _FakeLocalDataSource implements ArticleLocalDataSource {
  final List<ArticleModel> saved = [];

  @override
  Future<List<ArticleModel>> getArticles() async => saved;

  @override
  Future<void> removeArticle(ArticleModel article) async {
    saved.removeWhere((item) => item.id == article.id);
  }

  @override
  Future<void> saveArticle(ArticleModel article) async {
    saved.add(article);
  }
}

void main() {
  test('parses the NewsAPI response envelope and its article list', () {
    final response = NewsApiResponseModel.fromJson({
      'status': 'ok',
      'totalResults': 1,
      'articles': [
        {
          'author': 'Author',
          'title': 'Envelope article',
          'description': 'Description',
          'url': 'https://example.test/article',
          'urlToImage': 'https://example.test/image.jpg',
          'publishedAt': '2026-09-22T10:00:00Z',
          'content': 'Content',
        },
      ],
    });

    expect(response.status, 'ok');
    expect(response.totalResults, 1);
    expect(response.articles.single.title, 'Envelope article');
  });

  test('data source returns articles from a realistic HTTP envelope', () async {
    final response = NewsApiResponseModel.fromJson({
      'status': 'ok',
      'totalResults': 1,
      'articles': [
        {
          'author': 'Author',
          'title': 'Envelope article',
          'description': 'Description',
          'url': 'https://example.test/article',
          'urlToImage': 'https://example.test/image.jpg',
          'publishedAt': '2026-09-22T10:00:00Z',
          'content': 'Content',
        },
      ],
    });
    final httpResponse = HttpResponse(
      response,
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/top-headlines'),
        statusCode: 200,
      ),
    );

    final service = _FakeNewsApiService(httpResponse);
    final result = await NewsApiDataSource(
      service,
      apiKey: 'test-key',
    ).getNewsArticles();

    expect(result.single.title, 'Envelope article');
    expect(service.lastApiKey, 'test-key');
  });

  test('maps native provider rate limits to a quota message', () async {
    final request = RequestOptions(path: '/top-headlines');
    final error = DioException(
      requestOptions: request,
      response: Response(
        requestOptions: request,
        statusCode: 429,
      ),
    );

    await expectLater(
      NewsApiDataSource(
        _ThrowingNewsApiService(error),
        apiKey: 'test-key',
      ).getNewsArticles(),
      throwsA(
        isA<NewsApiException>().having(
          (exception) => exception.message,
          'message',
          'The external news provider has reached its request limit. Please try again later.',
        ),
      ),
    );
  });

  test('fails closed without calling NewsAPI when no key is configured',
      () async {
    final response = NewsApiResponseModel.fromJson({
      'status': 'ok',
      'totalResults': 0,
      'articles': const [],
    });
    final service = _FakeNewsApiService(HttpResponse(
      response,
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/top-headlines'),
        statusCode: 200,
      ),
    ));

    await expectLater(
      NewsApiDataSource(service, apiKey: '').getNewsArticles(),
      throwsA(
        isA<NewsApiException>().having(
          (exception) => exception.message,
          'message',
          'Latest news is currently unavailable from the external provider.',
        ),
      ),
    );
    expect(service.calls, 0);
  });

  test('repository maps remote models to provider-independent entities',
      () async {
    final repository = ArticleRepositoryImpl(
      _FakeRemoteDataSource(),
      _FakeLocalDataSource(),
    );

    final result = await repository.getNewsArticles();

    expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    expect(result.data!.single, isA<ArticleEntity>());
    expect(result.data!.single.title, 'Envelope article');
  });
}
