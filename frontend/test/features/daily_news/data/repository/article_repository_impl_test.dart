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

/// Replies like NewsAPI: [count] stories out of [totalResults].
class _FakeNewsApi implements NewsApiService {
  final int count;
  final int totalResults;

  /// What the last search asked for.
  String? searchedFor;
  String? searchedIn;
  String? searchedLanguage;

  _FakeNewsApi({required this.count, required this.totalResults});

  @override
  Future<HttpResponse<List<ArticleModel>>> getNewsArticles({
    String? apiKey,
    String? country,
    String? category,
    int? page,
    int? pageSize,
  }) async =>
      _reply();

  @override
  Future<HttpResponse<List<ArticleModel>>> searchArticles({
    String? apiKey,
    String? query,
    String? searchIn,
    String? language,
    String? sortBy,
    int? page,
    int? pageSize,
  }) async {
    searchedFor = query;
    searchedIn = searchIn;
    searchedLanguage = language;
    return _reply();
  }

  HttpResponse<List<ArticleModel>> _reply() {
    final models = [
      for (var i = 0; i < count; i++) ArticleModel(url: 'u$i', title: 't$i'),
    ];
    return HttpResponse(
      models,
      Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: {'status': 'ok', 'totalResults': totalResults},
      ),
    );
  }
}

class _UnusedDatabase implements AppDatabase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// None of these tests touch saved articles, so this is never actually
/// called -- just needed to satisfy the constructor.
class _UnusedCurrentUserDataSource implements CurrentUserDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<NewsPage> _page(int count, int total, {int page = 1}) async {
  final repository = ArticleRepositoryImpl(
    _FakeNewsApi(count: count, totalResults: total),
    _UnusedDatabase(),
    _UnusedCurrentUserDataSource(),
  );
  final result =
      await repository.getNewsArticles(NewsQuery(page: page, pageSize: 20));
  return (result as DataSuccess<NewsPage>).data!;
}

void main() {
  test('knows there is more even when a page comes back short', () async {
    // What NewsAPI really answered: 18 of 20 requested, 36 in total.
    expect((await _page(18, 36)).hasMore, isTrue);
  });

  test('knows the last page is the last one', () async {
    expect((await _page(16, 36, page: 2)).hasMore, isFalse);
  });

  test('search asks for the trimmed text, in the app language', () async {
    final api = _FakeNewsApi(count: 3, totalResults: 3);
    final repository = ArticleRepositoryImpl(
        api, _UnusedDatabase(), _UnusedCurrentUserDataSource());

    final result = await repository.searchArticles(
      const SearchQuery(text: '  climate  ', languageCode: 'es'),
    );

    expect(api.searchedFor, 'climate');
    expect(api.searchedLanguage, 'es');
    expect(api.searchedIn, 'title,description');
    expect((result as DataSuccess<NewsPage>).data!.articles, hasLength(3));
  });
}
