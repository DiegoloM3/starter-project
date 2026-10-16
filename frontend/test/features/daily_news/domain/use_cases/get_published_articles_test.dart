import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/published_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_published_articles.dart';

class MockPublishedArticleRepository extends Mock implements PublishedArticleRepository {}

void main() {
  group('GetPublishedArticlesUseCase', () {
    test('returns the published articles of the repository', () async {
      final repository = MockPublishedArticleRepository();
      final articles = [
        PublishedArticleEntity(
          title: 'Breaking News!',
          content: 'This is breaking news!',
          thumbnailUrl: 'https://example.com/thumbnail.jpg',
          publishedAt: DateTime.utc(2026, 10, 15),
        ),
      ];
      when(() => repository.getPublishedArticles()).thenAnswer((_) async => DataSuccess(articles));

      final result = await GetPublishedArticlesUseCase(repository)();

      expect(result.data, articles);
    });
  });
}
