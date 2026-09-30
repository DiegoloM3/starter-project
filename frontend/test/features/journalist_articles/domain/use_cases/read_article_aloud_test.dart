import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_narrator_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/read_article_aloud.dart';

class MockArticleNarratorRepository extends Mock implements ArticleNarratorRepository {}

final article = PublishedArticleEntity(
  id: 'article-1',
  title: 'Breaking News',
  content: 'The **body**.',
  description: 'The body.',
  author: 'Daily News Staff',
  thumbnailUrl: 'https://example.com/1.jpg',
  publishedAt: DateTime.utc(2026, 9, 28),
);

void main() {
  late MockArticleNarratorRepository repository;

  setUpAll(() => registerFallbackValue(const ArticleNarrationEntity(parts: [], languageTag: 'en-US')));

  setUp(() {
    repository = MockArticleNarratorRepository();
    when(() => repository.read(any())).thenAnswer((_) => const Stream.empty());
  });

  test('reads the narration of the article', () async {
    await ReadArticleAloudUseCase(repository)(params: article).drain<void>();

    verify(() => repository.read(ArticleNarrationEntity.of(article))).called(1);
  });

  test('does nothing without an article', () async {
    expect(await ReadArticleAloudUseCase(repository)().toList(), isEmpty);

    verifyNever(() => repository.read(any()));
  });
}
