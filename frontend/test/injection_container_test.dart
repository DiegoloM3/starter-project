import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class _FakeLocalArticleDataSource implements ArticleLocalDataSource {
  @override
  Future<List<ArticleModel>> getArticles() async => const [];

  @override
  Future<void> saveArticle(ArticleModel article) async {}

  @override
  Future<void> removeArticle(ArticleModel article) async {}
}

void main() {
  test('registers the bookmark datasource under its repository contract', () {
    final graph = GetIt.asNewInstance();
    addTearDown(graph.reset);
    final local = _FakeLocalArticleDataSource();

    registerLocalArticleDataSource(local, container: graph);

    expect(graph.isRegistered<ArticleLocalDataSource>(), isTrue);
    expect(graph<ArticleLocalDataSource>(), same(local));
  });

  test('preserves an existing bookmark datasource registration', () {
    final graph = GetIt.asNewInstance();
    addTearDown(graph.reset);
    final existing = _FakeLocalArticleDataSource();

    graph.registerSingleton<ArticleLocalDataSource>(existing);
    registerLocalArticleDataSource(
      _FakeLocalArticleDataSource(),
      container: graph,
    );

    expect(graph<ArticleLocalDataSource>(), same(existing));
  });

  test('rolls back partial initialization and allows a retry', () async {
    final graph = GetIt.asNewInstance();
    addTearDown(graph.reset);
    final existing = _FakeLocalArticleDataSource();
    graph.registerSingleton<ArticleLocalDataSource>(existing);

    Future<void> initialize() => initializeDependencies(
          container: graph,
          localDataSourceFactory: () async => existing,
        );

    await expectLater(initialize(), throwsA(anything));

    expect(graph<ArticleLocalDataSource>(), same(existing));
    expect(graph.isRegistered<Dio>(), isFalse);
    expect(graph.isRegistered<NewsApiService>(), isFalse);

    await expectLater(initialize(), throwsA(anything));

    expect(graph<ArticleLocalDataSource>(), same(existing));
    expect(graph.isRegistered<Dio>(), isFalse);
    expect(graph.isRegistered<NewsApiService>(), isFalse);
  });
}
