import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/get_published_articles_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_published_articles.dart';

import '../../../../helpers/article_fixtures.dart';
import '../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late GetPublishedArticlesUseCase getPublishedArticles;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    getPublishedArticles = GetPublishedArticlesUseCase(repository);
  });

  test('returns the published articles', () async {
    repository.publishedArticlesResult = DataSuccess([publishableArticle()]);

    final result =
        await getPublishedArticles(const GetPublishedArticlesParams());

    expect(result, isA<DataSuccess>());
    expect(result.data, hasLength(1));
  });

  test('forwards the author filter and the paging cursor', () async {
    await getPublishedArticles(const GetPublishedArticlesParams(
      limit: 5,
      authorId: 'journalist-1',
      excludeArticleId: 'article-1',
      startAfterArticleId: 'article-0',
    ));

    expect(repository.lastPublishedArticlesLimit, 5);
    expect(repository.lastPublishedArticlesAuthorId, 'journalist-1');
    expect(repository.lastPublishedArticlesExcludeArticleId, 'article-1');
    expect(repository.lastPublishedArticlesStartAfterArticleId, 'article-0');
  });

  test('asks for no time window unless one was requested', () async {
    await getPublishedArticles(const GetPublishedArticlesParams());

    expect(repository.lastPublishedAfter, isNull);
  });

  test('the recent feed asks for the last week only', () async {
    final now = DateTime(2026, 9, 22, 12);

    await getPublishedArticles(GetPublishedArticlesParams.recent(now: now));

    expect(repository.lastPublishedAfter, DateTime(2026, 9, 15, 12));
  });

  test('pages ten articles at a time by default', () async {
    await getPublishedArticles(const GetPublishedArticlesParams());

    expect(repository.lastPublishedArticlesLimit, 10);
  });
}
