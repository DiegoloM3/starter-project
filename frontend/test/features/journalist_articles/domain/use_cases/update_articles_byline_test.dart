import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/update_articles_byline_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/update_articles_byline.dart';

import '../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late UpdateArticlesBylineUseCase useCase;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    useCase = UpdateArticlesBylineUseCase(repository);
  });

  test('rewrites the byline on the author own articles', () async {
    repository.updateAuthorNameResult = const DataSuccess(3);

    final result = await useCase(const UpdateArticlesBylineParams(
      userId: 'journalist-1',
      authorName: 'Alex Rivera',
    ));

    expect(result, isA<DataSuccess<int>>());
    expect(result.data, 3);
    expect(repository.lastRenamedUserId, 'journalist-1');
    expect(repository.lastAuthorName, 'Alex Rivera');
  });

  test('trims the name before it reaches the articles', () async {
    await useCase(const UpdateArticlesBylineParams(
      userId: 'journalist-1',
      authorName: '  Alex Rivera  ',
    ));

    expect(repository.lastAuthorName, 'Alex Rivera');
  });

  /// Nothing signed goes out unsigned: a blank byline is refused here rather
  /// than wiping the name off a whole back catalogue.
  test('refuses a blank name without touching anything', () async {
    final result = await useCase(const UpdateArticlesBylineParams(
      userId: 'journalist-1',
      authorName: '   ',
    ));

    expect(result, isA<DataFailed<int>>());
    expect(result.error, isA<ArticleValidationException>());
    expect(
      (result.error as ArticleValidationException).errors,
      contains(ArticleValidationError.authorRequired),
    );
    expect(repository.updateAuthorNameCallCount, 0);
  });

  test('refuses to rename the articles of nobody in particular', () async {
    final result = await useCase(const UpdateArticlesBylineParams(
      userId: '',
      authorName: 'Alex Rivera',
    ));

    expect(result, isA<DataFailed<int>>());
    expect(
      (result.error as ArticleValidationException).errors,
      contains(ArticleValidationError.userRequired),
    );
    expect(repository.updateAuthorNameCallCount, 0);
  });

  /// An author who has not written yet is not an error, just a rename with
  /// nothing to rename.
  test('zero articles is an ordinary answer', () async {
    repository.updateAuthorNameResult = const DataSuccess(0);

    final result = await useCase(const UpdateArticlesBylineParams(
      userId: 'journalist-1',
      authorName: 'Alex Rivera',
    ));

    expect(result, isA<DataSuccess<int>>());
    expect(result.data, 0);
  });

  test('reports what the repository refused', () async {
    repository.updateAuthorNameResult =
        const DataFailed(ArticleNotStoredException());

    final result = await useCase(const UpdateArticlesBylineParams(
      userId: 'journalist-1',
      authorName: 'Alex Rivera',
    ));

    expect(result, isA<DataFailed<int>>());
    expect(result.error, isA<ArticleNotStoredException>());
  });
}
