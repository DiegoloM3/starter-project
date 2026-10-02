import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/is_article_saved.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  test('asks the repository whether the news article is saved', () async {
    const article = ArticleEntity(title: 'A headline', url: 'https://example.com/news');
    final repository = MockArticleRepository();
    when(() => repository.isArticleSaved(article)).thenAnswer((_) async => const DataSuccess(true));

    final dataState = await IsArticleSavedUseCase(repository)(params: article);

    expect(dataState.data, isTrue);
  });
}
