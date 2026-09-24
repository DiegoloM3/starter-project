import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_feed/article_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_feed/article_feed_state.dart';

import '../../../../../helpers/article_fixtures.dart';
import '../../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;

  setUp(() {
    repository = FakeJournalistArticleRepository();
  });

  test('loads the general feed with no author filter', () async {
    final cubit = ArticleFeedCubit(GetPublishedArticlesUseCase(repository));
    repository.publishedArticlesResult = DataSuccess([publishableArticle()]);

    await cubit.loadFeed();

    expect(cubit.state.status, ArticleFeedStatus.success);
    expect(cubit.state.articles, hasLength(1));
    expect(repository.lastPublishedArticlesAuthorId, isNull);
  });

  test('scopes the feed to one author when constructed with authorId',
      () async {
    final cubit = ArticleFeedCubit(
      GetPublishedArticlesUseCase(repository),
      authorId: 'journalist-1',
      excludeArticleId: 'article-1',
    );

    await cubit.loadFeed();

    expect(repository.lastPublishedArticlesAuthorId, 'journalist-1');
    expect(repository.lastPublishedArticlesExcludeArticleId, 'article-1');
  });

  test('the community feed asks only for the last week', () async {
    final cubit = ArticleFeedCubit(GetPublishedArticlesUseCase(repository));

    await cubit.loadFeed();

    expect(repository.lastPublishedAfter, isNotNull);
    await cubit.close();
  });

  test("an author's own feed is not limited to the last week", () async {
    // Their catalogue should not empty itself after seven days.
    final cubit = ArticleFeedCubit(
      GetPublishedArticlesUseCase(repository),
      authorId: 'journalist-1',
      onlyRecent: false,
    );

    await cubit.loadFeed();

    expect(repository.lastPublishedAfter, isNull);
    await cubit.close();
  });

  test('reports a failure without crashing', () async {
    final cubit = ArticleFeedCubit(GetPublishedArticlesUseCase(repository));
    repository.publishedArticlesResult =
        const DataFailed(FormatException('boom'));

    await cubit.loadFeed();

    expect(cubit.state.status, ArticleFeedStatus.failure);
    expect(cubit.state.error, isA<FormatException>());
  });

  test('loadMore pages after the last loaded article, appending results',
      () async {
    // A full page (one article, matching pageSize) signals there may be more.
    final cubit = ArticleFeedCubit(
      GetPublishedArticlesUseCase(repository),
      pageSize: 1,
    );
    repository.publishedArticlesResult =
        DataSuccess([publishableArticle(id: 'a-1')]);
    await cubit.loadFeed();

    repository.publishedArticlesResult =
        DataSuccess([publishableArticle(id: 'a-2')]);
    await cubit.loadMore();

    expect(repository.lastPublishedArticlesStartAfterArticleId, 'a-1');
    expect(
      cubit.state.articles.map((article) => article.id).toList(),
      ['a-1', 'a-2'],
    );
  });

  test('marks the feed exhausted once a shorter-than-requested page comes back',
      () async {
    final cubit = ArticleFeedCubit(
      GetPublishedArticlesUseCase(repository),
      pageSize: 5,
    );
    repository.publishedArticlesResult =
        DataSuccess([publishableArticle(id: 'a-1')]);

    await cubit.loadFeed();

    expect(cubit.state.hasMore, isFalse);
  });
}
