import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/journalist_article_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_published_articles.dart';

class MockJournalistArticleRepository extends Mock implements JournalistArticleRepository {}

void main() {
  late MockJournalistArticleRepository repository;
  late GetPublishedArticlesUseCase getPublishedArticles;

  setUp(() {
    repository = MockJournalistArticleRepository();
    getPublishedArticles = GetPublishedArticlesUseCase(repository);
  });

  test('returns the published articles from the repository', () async {
    final articles = [
      JournalistArticleEntity(
        id: 'article1',
        title: 'Local startup brings clean water to 10,000 homes',
        description: 'A team of engineers has designed a low-cost filter.',
        content: 'When the first prototype was installed last spring...',
        author: 'Jane Doe',
        authorId: 'janeDoeUid',
        thumbnailURL: 'https://example.com/thumbnail.png',
        publishedAt: DateTime.utc(2026, 9, 30),
      ),
    ];
    when(() => repository.getPublishedArticles()).thenAnswer((_) async => DataSuccess(articles));

    final dataState = await getPublishedArticles();

    expect(dataState, isA<DataSuccess>());
    expect(dataState.data, articles);
  });

  test('returns the failure of the repository', () async {
    final error = Exception('No connection');
    when(() => repository.getPublishedArticles()).thenAnswer((_) async => DataFailed(error));

    final dataState = await getPublishedArticles();

    expect(dataState, isA<DataFailed>());
    expect(dataState.error, error);
  });
}
