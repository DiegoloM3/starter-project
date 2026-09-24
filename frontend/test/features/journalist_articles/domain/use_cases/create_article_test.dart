import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/create_article.dart';

import '../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late CreateArticleUseCase createArticle;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    createArticle = CreateArticleUseCase(repository);
  });

  const validDraftParams = CreateArticleParams(
    title: 'The night bus driver who knows everyone',
    author: 'Alex Rivera',
    userId: 'journalist-1',
  );

  test('stores a draft built from the params', () async {
    final result = await createArticle(validDraftParams);

    expect(result, isA<DataSuccess>());
    expect(repository.createCallCount, 1);
    expect(repository.lastCreatedArticle?.title, validDraftParams.title);
    expect(repository.lastCreatedArticle?.userId, validDraftParams.userId);
    expect(repository.lastCreatedArticle?.status, ArticleStatus.draft);
    expect(repository.lastCreatedArticle?.isStored, isFalse);
  });

  test('rejects a draft without a title and never reaches the repository',
      () async {
    const params = CreateArticleParams(
      title: '',
      author: 'Alex Rivera',
      userId: 'journalist-1',
    );

    final result = await createArticle(params);

    expect(result, isA<DataFailed>());
    expect(
      (result.error as ArticleValidationException).errors,
      contains(ArticleValidationError.titleRequired),
    );
    expect(repository.createCallCount, 0);
  });

  test('applies the publishing rules when the article is created published',
      () async {
    const params = CreateArticleParams(
      title: 'The night bus driver who knows everyone',
      author: 'Alex Rivera',
      userId: 'journalist-1',
      status: ArticleStatus.published,
    );

    final result = await createArticle(params);

    expect(result, isA<DataFailed>());
    expect(
      (result.error as ArticleValidationException).errors,
      containsAll(<ArticleValidationError>[
        ArticleValidationError.descriptionRequired,
        ArticleValidationError.contentRequired,
        ArticleValidationError.thumbnailRequired,
      ]),
    );
    expect(repository.createCallCount, 0);
  });

  test('propagates a repository failure', () async {
    repository.createResult = const DataFailed('firestore is unreachable');

    final result = await createArticle(validDraftParams);

    expect(result, isA<DataFailed>());
    expect(result.error, 'firestore is unreachable');
  });
}
