import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_articles_by_category.dart';

import '../../../../fixtures/test_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late GetArticlesByCategoryUseCase useCase;
  late MockUserArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockUserArticleRepository();
    useCase = GetArticlesByCategoryUseCase(mockRepository);
  });

  group('GetArticlesByCategoryUseCase', () {
    const testCategory = 'Technology';
    final technologyArticles = TestFixtures.technologyArticles;

    test('should return DataSuccess with filtered articles when successful',
        () async {
      // Arrange
      when(mockRepository.getArticlesByCategory(testCategory))
          .thenAnswer((_) async => DataSuccess(technologyArticles));

      // Act
      final result = await useCase(params: testCategory);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, technologyArticles);
      verify(mockRepository.getArticlesByCategory(testCategory)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return only articles matching the category', () async {
      // Arrange
      when(mockRepository.getArticlesByCategory(testCategory))
          .thenAnswer((_) async => DataSuccess(technologyArticles));

      // Act
      final result = await useCase(params: testCategory);

      // Assert
      final articles = (result as DataSuccess).data!;
      for (final article in articles) {
        expect(article.categories, contains(testCategory));
      }
    });

    test('should return empty list when no articles match category', () async {
      // Arrange
      const nonExistentCategory = 'NonExistentCategory';
      when(mockRepository.getArticlesByCategory(nonExistentCategory))
          .thenAnswer((_) async => DataSuccess([]));

      // Act
      final result = await useCase(params: nonExistentCategory);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, isEmpty);
    });

    test('should return DataFailed when repository fails', () async {
      // Arrange
      final exception = Exception('Failed to fetch articles');
      when(mockRepository.getArticlesByCategory(testCategory))
          .thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(params: testCategory);

      // Assert
      expect(result, isA<DataFailed>());
    });

    test('should return DataFailed when category is null', () async {
      // Act
      final result = await useCase(params: null);

      // Assert
      expect(result, isA<DataFailed>());
      verifyNever(mockRepository.getArticlesByCategory(any));
    });

    test('should handle case-sensitive category matching', () async {
      // Arrange
      const lowercaseCategory = 'technology';
      when(mockRepository.getArticlesByCategory(lowercaseCategory))
          .thenAnswer((_) async => DataSuccess([]));

      // Act
      await useCase(params: lowercaseCategory);

      // Assert
      verify(mockRepository.getArticlesByCategory(lowercaseCategory)).called(1);
    });
  });
}
