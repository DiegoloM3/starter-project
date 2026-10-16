import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/published_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';

class MockPublishedArticleRepository extends Mock implements PublishedArticleRepository {}

void main() {
  late MockPublishedArticleRepository repository;
  late PublishArticleUseCase publishArticle;

  setUpAll(() {
    registerFallbackValue(const ArticleDraftEntity(title: '', content: ''));
  });

  setUp(() {
    repository = MockPublishedArticleRepository();
    publishArticle = PublishArticleUseCase(repository);
  });

  group('PublishArticleUseCase', () {
    test('publishes a draft that is ready to publish', () async {
      const draft = ArticleDraftEntity(
        title: 'Breaking News!',
        content: 'This is breaking news!',
        thumbnailPath: '/images/thumbnail.jpg',
      );
      when(() => repository.publishArticle(draft)).thenAnswer((_) async => const DataSuccess(null));

      final result = await publishArticle(params: const PublishArticleParams(draft));

      expect(result, isA<DataSuccess<void>>());
      verify(() => repository.publishArticle(draft)).called(1);
    });

    test('returns the failure of the repository', () async {
      const draft = ArticleDraftEntity(title: 'Title', content: 'Content', thumbnailPath: '/a.jpg');
      final error = Exception('No connection');
      when(() => repository.publishArticle(draft)).thenAnswer((_) async => DataFailed(error));

      final result = await publishArticle(params: const PublishArticleParams(draft));

      expect(result.error, error);
    });

    test('fails with the validation errors of an invalid draft without publishing it', () async {
      const draft = ArticleDraftEntity(title: '', content: 'Content');

      final result = await publishArticle(params: const PublishArticleParams(draft));

      expect(result, isA<DataFailed<void>>());
      final error = result.error as ArticleDraftValidationException;
      expect(error.errors, [ArticleDraftError.emptyTitle, ArticleDraftError.missingThumbnail]);
      verifyNever(() => repository.publishArticle(any()));
    });
  });
}
