import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/delete_article.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late DeleteArticleUseCase useCase;
  late MockUserArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockUserArticleRepository();
    useCase = DeleteArticleUseCase(mockRepository);
  });

  group('DeleteArticleUseCase', () {
    const testArticleId = 'test-article-id';

    test('should return DataSuccess when deletion is successful', () async {
      // Arrange
      when(mockRepository.deleteArticle(testArticleId))
          .thenAnswer((_) async => DataSuccess(null));

      // Act
      final result = await useCase(params: testArticleId);

      // Assert
      expect(result, isA<DataSuccess>());
      verify(mockRepository.deleteArticle(testArticleId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DataFailed when deletion fails', () async {
      // Arrange
      final exception = Exception('Article not found');
      when(mockRepository.deleteArticle(testArticleId))
          .thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(params: testArticleId);

      // Assert
      expect(result, isA<DataFailed>());
      verify(mockRepository.deleteArticle(testArticleId)).called(1);
    });

    test('should return DataFailed when articleId is null', () async {
      // Act
      final result = await useCase(params: null);

      // Assert
      expect(result, isA<DataFailed>());
      verifyNever(mockRepository.deleteArticle(any));
    });

    test('should pass correct articleId to repository', () async {
      // Arrange
      const specificId = 'specific-article-id';
      when(mockRepository.deleteArticle(specificId))
          .thenAnswer((_) async => DataSuccess(null));

      // Act
      await useCase(params: specificId);

      // Assert
      verify(mockRepository.deleteArticle(specificId)).called(1);
    });
  });
}
