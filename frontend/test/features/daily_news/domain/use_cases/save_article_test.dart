import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';

import '../../../../helpers/fake_article_repository.dart';

void main() {
  late FakeArticleRepository repository;
  late SaveArticleUseCase useCase;

  setUp(() {
    repository = FakeArticleRepository();
    useCase = SaveArticleUseCase(repository);
  });

  test('keeps the article it was given', () async {
    final result = await useCase(newsArticle());

    expect(result, isA<DataSuccess>());
    expect(repository.savedArticles, hasLength(1));
  });

  test('keeping the same article twice leaves one copy', () async {
    await useCase(newsArticle());
    await useCase(newsArticle());

    expect(repository.savedArticles, hasLength(1));
  });

  test('reports a write that did not happen', () async {
    repository.writeResult = DataFailed(Exception('disk full'));

    expect(await useCase(newsArticle()), isA<DataFailed>());
  });
}
