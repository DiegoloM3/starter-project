import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles.dart';

import 'article_test_data.dart';

void main() {
  test('gets the articles from the repository', () async {
    final repository = MockArticleRepository();
    when(() => repository.getArticles()).thenAnswer((_) async => DataSuccess([testArticle]));

    final result = await GetArticlesUseCase(repository).call(const NoParams());

    expect(result.data, [testArticle]);
  });
}
