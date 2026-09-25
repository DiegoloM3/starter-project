import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/data/data_sources/remote/current_user_data_source.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:retrofit/retrofit.dart';

/// NewsAPI that can lose its connection mid-test, or start answering with
/// its own free-plan daily cap instead.
class _FlakyNewsApi implements NewsApiService {
  bool offline = false;
  bool rateLimited = false;

  @override
  Future<HttpResponse<List<ArticleModel>>> getNewsArticles({
    String? apiKey,
    String? country,
    String? category,
    int? page,
    int? pageSize,
  }) async {
    if (offline) {
      throw DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      );
    }
    if (rateLimited) {
      final requestOptions = RequestOptions();
      throw DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 429,
          data: {'status': 'error', 'code': 'rateLimited'},
        ),
      );
    }
    return HttpResponse(
      [
        const ArticleModel(url: 'u1', title: 'First', sourceName: 'BBC News'),
        const ArticleModel(url: 'u2', title: 'Second'),
      ],
      Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: {'status': 'ok', 'totalResults': 2},
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// None of these tests touch saved articles, so this is never actually
/// called -- just needed to satisfy the constructor.
class _UnusedCurrentUserDataSource implements CurrentUserDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Runs against a real in-memory SQLite database, like the app's.
void main() {
  late AppDatabase database;
  late _FlakyNewsApi api;
  late ArticleRepositoryImpl repository;

  setUp(() async {
    database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    api = _FlakyNewsApi();
    repository =
        ArticleRepositoryImpl(api, database, _UnusedCurrentUserDataSource());
  });

  tearDown(() => database.close());

  test('offline, answers with the copy saved when it was online', () async {
    final online = await repository.getNewsArticles(const NewsQuery());
    expect((online as DataSuccess<NewsPage>).data!.isOfflineCopy, isFalse);

    api.offline = true;
    final offline = await repository.getNewsArticles(const NewsQuery());

    final page = (offline as DataSuccess<NewsPage>).data!;
    expect(page.isOfflineCopy, isTrue);
    expect(page.articles.map((a) => a.title), ['First', 'Second']);
    expect(page.articles.first.sourceName, 'BBC News');
    expect(page.hasMore, isFalse);
  });

  test('keeps each section\'s copy apart', () async {
    await repository.getNewsArticles(const NewsQuery());
    api.offline = true;

    final sports = await repository
        .getNewsArticles(const NewsQuery(category: NewsCategory.sports));

    expect(sports, isA<DataFailed<NewsPage>>());
  });

  test('offline with nothing saved yet, it fails as before', () async {
    api.offline = true;

    final result = await repository.getNewsArticles(const NewsQuery());

    expect(result, isA<DataFailed<NewsPage>>());
  });

  test(
      'NewsAPI\'s own daily cap answers with the saved copy too, but marked '
      'as a different reason than "offline"', () async {
    await repository.getNewsArticles(const NewsQuery());

    api.rateLimited = true;
    final result = await repository.getNewsArticles(const NewsQuery());

    final page = (result as DataSuccess<NewsPage>).data!;
    expect(page.isOfflineCopy, isTrue);
    expect(page.isRateLimited, isTrue);
  });
}
