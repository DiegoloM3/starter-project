import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/save_article.dart';

import 'article_test_data.dart';

void main() {
  test('saves the article through the repository', () async {
    final repository = MockSavedArticlesRepository();
    when(() => repository.saveArticle(testArticle.id)).thenAnswer((_) async => const DataSuccess(null));

    final result = await SaveArticleUseCase(repository).call(testArticle.id);

    expect(result, isA<DataSuccess>());
    verify(() => repository.saveArticle(testArticle.id)).called(1);
  });
}
