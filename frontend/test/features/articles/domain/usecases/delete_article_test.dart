import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/delete_article.dart';

import 'article_test_data.dart';

void main() {
  test('deletes the article through the repository', () async {
    final repository = MockArticleRepository();
    when(() => repository.deleteArticle(testArticle.id)).thenAnswer((_) async => const DataSuccess(null));

    final result = await DeleteArticleUseCase(repository).call(testArticle.id);

    expect(result, isA<DataSuccess>());
    verify(() => repository.deleteArticle(testArticle.id)).called(1);
  });
}
