import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/get_published_articles_use_case.dart';

import '../../support/fake_read_published_articles_repository.dart';

void main() {
  test('returns published articles from the repository', () async {
    final repository = FakeReadPublishedArticlesRepository()
      ..articles = [publishedArticle()];
    final useCase = GetPublishedArticlesUseCase(repository);

    final result = await useCase();

    expect(result, repository.articles);
    expect(repository.calls, 1);
  });

  test('propagates repository failures', () async {
    final repository = FakeReadPublishedArticlesRepository()
      ..error = StateError('unavailable');
    final useCase = GetPublishedArticlesUseCase(repository);

    await expectLater(useCase(), throwsA(isA<StateError>()));
  });
}
