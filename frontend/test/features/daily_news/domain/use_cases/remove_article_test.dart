import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_article.dart';

import '../../../../helpers/fake_article_repository.dart';

void main() {
  late FakeArticleRepository repository;
  late RemoveArticleUseCase useCase;

  setUp(() {
    repository = FakeArticleRepository();
    useCase = RemoveArticleUseCase(repository);
  });

  test('drops the article it was given', () async {
    repository.savedArticles.add(newsArticle());

    final result = await useCase(newsArticle());

    expect(result, isA<DataSuccess>());
    expect(repository.savedArticles, isEmpty);
  });

  test('an article that was never kept is left alone', () async {
    repository.savedArticles.add(newsArticle());

    await useCase(newsArticle(url: 'https://example.com/something-else'));

    expect(repository.savedArticles, hasLength(1));
  });

  test('reports a removal that did not happen', () async {
    repository.writeResult = DataFailed(Exception('disk error'));

    expect(await useCase(newsArticle()), isA<DataFailed>());
  });
}
