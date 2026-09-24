import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';

import '../../../../helpers/article_fixtures.dart';
import '../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late PublishArticleUseCase publishArticle;

  final publishedAt = DateTime(2026, 9, 22, 8, 0);

  setUp(() {
    repository = FakeJournalistArticleRepository();
    publishArticle = PublishArticleUseCase(repository);
  });

  test('publishes a complete draft at the given moment', () async {
    final result = await publishArticle(
      PublishArticleParams(publishableArticle(), publishedAt: publishedAt),
    );

    expect(result, isA<DataSuccess>());
    expect(repository.lastUpdatedArticle?.status, ArticleStatus.published);
    expect(repository.lastUpdatedArticle?.publishedAt, publishedAt);
  });

  test('refuses to publish an incomplete draft', () async {
    final incomplete = publishableArticle().copyWith(thumbnailUrl: '');

    final result = await publishArticle(
      PublishArticleParams(incomplete, publishedAt: publishedAt),
    );

    expect(result, isA<DataFailed>());
    expect(
      (result.error as ArticleValidationException).errors,
      contains(ArticleValidationError.thumbnailRequired),
    );
    expect(repository.updateCallCount, 0);
  });

  test('refuses to publish an article that was never stored', () async {
    final neverStored = publishableArticle(id: '');

    final result = await publishArticle(
      PublishArticleParams(neverStored, publishedAt: publishedAt),
    );

    expect(result, isA<DataFailed>());
    expect(result.error, isA<ArticleNotStoredException>());
    expect(repository.updateCallCount, 0);
  });

  test('defaults the publication moment to now', () {
    final params = PublishArticleParams(publishableArticle());

    expect(
      params.publishedAt.difference(DateTime.now()).inSeconds.abs(),
      lessThan(2),
    );
  });
}
