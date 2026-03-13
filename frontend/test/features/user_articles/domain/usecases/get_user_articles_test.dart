import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_user_articles.dart';

import '../../../../fixtures/test_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late GetUserArticlesUseCase useCase;
  late MockUserArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockUserArticleRepository();
    useCase = GetUserArticlesUseCase(mockRepository);
  });

  group('GetUserArticlesUseCase', () {
    const testUserId = 'test-user-id';
    final userArticles = TestFixtures.testArticleList;

    test('should return DataSuccess with user articles when successful',
        () async {
      // Arrange
      when(mockRepository.getUserArticles(testUserId))
          .thenAnswer((_) async => DataSuccess(userArticles));

      // Act
      final result = await useCase(params: testUserId);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, userArticles);
      verify(mockRepository.getUserArticles(testUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return articles including both published and drafts',
        () async {
      // Arrange
      when(mockRepository.getUserArticles(testUserId))
          .thenAnswer((_) async => DataSuccess(userArticles));

      // Act
      final result = await useCase(params: testUserId);

      // Assert
      final articles = (result as DataSuccess).data!;
      var draftCount = 0;
      var publishedCount = 0;
      for (final article in articles) {
        if (article.isDraft) {
          draftCount++;
        } else {
          publishedCount++;
        }
      }
      expect(draftCount > 0, true);
      expect(publishedCount > 0, true);
    });

    test('should return empty list when user has no articles', () async {
      // Arrange
      when(mockRepository.getUserArticles(testUserId))
          .thenAnswer((_) async => DataSuccess([]));

      // Act
      final result = await useCase(params: testUserId);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, isEmpty);
    });

    test('should return DataFailed when repository fails', () async {
      // Arrange
      final exception = Exception('Failed to fetch user articles');
      when(mockRepository.getUserArticles(testUserId))
          .thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(params: testUserId);

      // Assert
      expect(result, isA<DataFailed>());
    });

    test('should return DataFailed when userId is null', () async {
      // Act
      final result = await useCase(params: null);

      // Assert
      expect(result, isA<DataFailed>());
      verifyNever(mockRepository.getUserArticles(any));
    });

    test('should filter articles by authorId matching userId', () async {
      // Arrange
      when(mockRepository.getUserArticles(testUserId))
          .thenAnswer((_) async => DataSuccess(userArticles));

      // Act
      final result = await useCase(params: testUserId);

      // Assert
      final articles = (result as DataSuccess).data!;
      for (final article in articles) {
        expect(article.authorId, testUserId);
      }
    });
  });
}
