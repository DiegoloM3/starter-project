import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_article.dart';

import 'article_test_data.dart';

void main() {
  test('gets the article from the repository', () async {
    final repository = MockArticleRepository();
    when(() => repository.getArticle(testArticle.id)).thenAnswer((_) async => DataSuccess(testArticle));

    final result = await GetArticleUseCase(repository).call(testArticle.id);

    expect(result.data, testArticle);
  });
}
