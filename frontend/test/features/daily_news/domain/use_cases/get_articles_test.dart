import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_articles.dart';

import '../../../../helpers/fake_article_repository.dart';

void main() {
  late FakeArticleRepository repository;
  late GetArticlesUseCase useCase;

  setUp(() {
    repository = FakeArticleRepository();
    useCase = GetArticlesUseCase(repository);
  });

  test('asks for the section it was given', () async {
    await useCase(NewsCategory.technology);

    expect(repository.lastRequestedCategory, NewsCategory.technology);
  });

  test('hands the headlines back untouched', () async {
    repository.newsArticlesResult = DataSuccess([newsArticle()]);

    final result = await useCase(NewsCategory.general);

    expect(result, isA<DataSuccess>());
    expect(result.data, hasLength(1));
  });

  test('passes a failure along rather than swallowing it', () async {
    repository.newsArticlesResult = DataFailed(Exception('offline'));

    expect(await useCase(NewsCategory.general), isA<DataFailed>());
  });
}
