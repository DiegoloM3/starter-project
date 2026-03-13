import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/publish_article.dart';

import '../../../../fixtures/test_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late PublishArticleUseCase useCase;
  late MockUserArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockUserArticleRepository();
    useCase = PublishArticleUseCase(mockRepository);
  });

  group('PublishArticleUseCase', () {
    const testArticleId = 'test-draft-id';
    final draftArticle = TestFixtures.testDraftArticle;
    final publishedArticle = draftArticle.copyWith(
      isDraft: false,
      publishedAt: DateTime.now(),
    );

    test('should return DataSuccess with published article when successful',
        () async {
      // Arrange
      when(mockRepository.publishArticle(testArticleId))
          .thenAnswer((_) async => DataSuccess(publishedArticle));

      // Act
      final result = await useCase(params: testArticleId);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data?.isDraft, false);
      verify(mockRepository.publishArticle(testArticleId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should set isDraft to false after publishing', () async {
      // Arrange
      when(mockRepository.publishArticle(testArticleId))
          .thenAnswer((_) async => DataSuccess(publishedArticle));

      // Act
      final result = await useCase(params: testArticleId);

      // Assert
      final article = (result as DataSuccess).data;
      expect(article?.isDraft, false);
    });

    test('should set publishedAt timestamp after publishing', () async {
      // Arrange
      when(mockRepository.publishArticle(testArticleId))
          .thenAnswer((_) async => DataSuccess(publishedArticle));

      // Act
      final result = await useCase(params: testArticleId);

      // Assert
      final article = (result as DataSuccess).data;
      expect(article?.publishedAt, isNotNull);
    });

    test('should return DataFailed when publishing fails', () async {
      // Arrange
      final exception = Exception('Article not found');
      when(mockRepository.publishArticle(testArticleId))
          .thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(params: testArticleId);

      // Assert
      expect(result, isA<DataFailed>());
    });

    test('should return DataFailed when articleId is null', () async {
      // Act
      final result = await useCase(params: null);

      // Assert
      expect(result, isA<DataFailed>());
      verifyNever(mockRepository.publishArticle(any));
    });

    test('should pass correct articleId to repository', () async {
      // Arrange
      const specificId = 'specific-draft-id';
      when(mockRepository.publishArticle(specificId))
          .thenAnswer((_) async => DataSuccess(publishedArticle));

      // Act
      await useCase(params: specificId);

      // Assert
      verify(mockRepository.publishArticle(specificId)).called(1);
    });
  });
}
