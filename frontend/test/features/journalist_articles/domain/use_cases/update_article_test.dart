import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/update_article.dart';

import '../../../../helpers/article_fixtures.dart';
import '../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late UpdateArticleUseCase updateArticle;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    updateArticle = UpdateArticleUseCase(repository);
  });

  test('saves the edits of a stored article', () async {
    final edited = publishableArticle().copyWith(title: 'A better title');

    final result = await updateArticle(UpdateArticleParams(edited));

    expect(result, isA<DataSuccess>());
    expect(repository.lastUpdatedArticle?.title, 'A better title');
  });

  test('refuses to update an article that was never stored', () async {
    final neverStored = publishableArticle(id: '').copyWith();

    final result = await updateArticle(UpdateArticleParams(neverStored));

    expect(result, isA<DataFailed>());
    expect(result.error, isA<ArticleNotStoredException>());
    expect(repository.updateCallCount, 0);
  });

  test('keeps a published article complete', () async {
    final brokenPublished =
        publishableArticle(status: ArticleStatus.published).copyWith(
      content: '',
    );

    final result = await updateArticle(UpdateArticleParams(brokenPublished));

    expect(result, isA<DataFailed>());
    expect(
      (result.error as ArticleValidationException).errors,
      contains(ArticleValidationError.contentRequired),
    );
    expect(repository.updateCallCount, 0);
  });

  test('allows a draft to stay incomplete', () async {
    final incompleteDraft = publishableArticle().copyWith(content: '');

    final result = await updateArticle(UpdateArticleParams(incompleteDraft));

    expect(result, isA<DataSuccess>());
    expect(repository.updateCallCount, 1);
  });
}
