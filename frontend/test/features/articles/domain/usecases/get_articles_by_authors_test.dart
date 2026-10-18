import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles_by_authors.dart';

import 'article_test_data.dart';

void main() {
  test('gets the articles of the authors from the repository', () async {
    final repository = MockArticleRepository();
    when(() => repository.getArticlesByAuthors(['journalist-1'])).thenAnswer((_) async => DataSuccess([testArticle]));

    final result = await GetArticlesByAuthorsUseCase(repository).call(['journalist-1']);

    expect(result.data, [testArticle]);
  });

  test('returns no articles without asking the repository when there are no authors', () async {
    final repository = MockArticleRepository();

    final result = await GetArticlesByAuthorsUseCase(repository).call(const []);

    expect(result.data, isEmpty);
    verifyNever(() => repository.getArticlesByAuthors(any()));
  });
}
