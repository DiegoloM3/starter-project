import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/saved_journalist_article_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_saved_journalist_articles.dart';

class MockSavedJournalistArticleRepository extends Mock implements SavedJournalistArticleRepository {}

void main() {
  test('returns the saved articles from the repository', () async {
    final repository = MockSavedJournalistArticleRepository();
    final articles = [
      JournalistArticleEntity(
        id: 'article1',
        title: 'Local startup brings clean water to 10,000 homes',
        description: 'A team of engineers has designed a low-cost filter.',
        content: 'When the first prototype was installed last spring...',
        author: 'Jane Doe',
        authorId: 'janeDoeUid',
        thumbnailURL: '',
        publishedAt: DateTime.utc(2026, 9, 30),
      ),
    ];
    when(() => repository.getSavedArticles()).thenAnswer((_) async => DataSuccess(articles));

    final dataState = await GetSavedJournalistArticlesUseCase(repository)();

    expect(dataState.data, articles);
  });
}
