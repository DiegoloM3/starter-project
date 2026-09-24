import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/delete_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/my_articles/my_articles_state.dart';

import '../../../../../helpers/article_fixtures.dart';
import '../../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late MyArticlesCubit cubit;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    cubit = MyArticlesCubit(
      GetMyArticlesUseCase(repository),
      PublishArticleUseCase(repository),
      DeleteArticleUseCase(repository),
      journalistId: 'journalist-1',
    );
  });

  tearDown(() => cubit.close());

  test('loads the articles of the signed in journalist', () async {
    repository.userArticlesResult = DataSuccess([publishableArticle()]);

    await cubit.loadArticles();

    expect(cubit.state.status, MyArticlesStatus.success);
    expect(cubit.state.articles, hasLength(1));
    expect(repository.lastUserId, 'journalist-1');
  });

  test('reports a failure without losing the screen state', () async {
    repository.userArticlesResult = const DataFailed('firestore is down');

    await cubit.loadArticles();

    expect(cubit.state.status, MyArticlesStatus.failure);
    expect(cubit.state.error, 'firestore is down');
  });

  test('reloads the list when the status filter changes', () async {
    await cubit.filterByStatus(ArticleStatus.draft);

    expect(cubit.state.statusFilter, ArticleStatus.draft);
    expect(repository.lastStatusFilter, ArticleStatus.draft);
  });

  test('clears the status filter when all articles are requested', () async {
    await cubit.filterByStatus(ArticleStatus.draft);
    await cubit.filterByStatus(null);

    expect(cubit.state.statusFilter, isNull);
    expect(repository.lastStatusFilter, isNull);
  });

  test('keeps the search query when reloading', () async {
    await cubit.search('bus');

    expect(cubit.state.searchQuery, 'bus');
    expect(repository.lastSearchQuery, 'bus');
  });

  test('deletes an article and refreshes the list', () async {
    await cubit.deleteArticle('article-1');

    expect(repository.lastDeletedArticleId, 'article-1');
    expect(cubit.state.status, MyArticlesStatus.success);
  });

  test('surfaces the rules that stop an article from being published',
      () async {
    final incomplete = publishableArticle().copyWith(content: '');

    await cubit.publishArticle(incomplete);

    expect(cubit.state.status, MyArticlesStatus.failure);
    expect(
      (cubit.state.error as ArticleValidationException).errors,
      contains(ArticleValidationError.contentRequired),
    );
    expect(repository.updateCallCount, 0);
  });

  test('publishes a complete draft and refreshes the list', () async {
    await cubit.publishArticle(publishableArticle());

    expect(repository.lastUpdatedArticle?.status, ArticleStatus.published);
    expect(cubit.state.status, MyArticlesStatus.success);
  });
}
