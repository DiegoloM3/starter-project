import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/remove_saved_article.dart';

import 'article_test_data.dart';

void main() {
  test('removes the saved article through the repository', () async {
    final repository = MockSavedArticlesRepository();
    when(() => repository.removeSavedArticle(testArticle.id)).thenAnswer((_) async => const DataSuccess(null));

    final result = await RemoveSavedArticleUseCase(repository).call(testArticle.id);

    expect(result, isA<DataSuccess>());
    verify(() => repository.removeSavedArticle(testArticle.id)).called(1);
  });
}
