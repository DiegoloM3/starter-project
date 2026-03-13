import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/update_article.dart';

import '../../../../fixtures/test_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late UpdateArticleUseCase useCase;
  late MockUserArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockUserArticleRepository();
    useCase = UpdateArticleUseCase(mockRepository);
  });

  group('UpdateArticleUseCase', () {
    final existingArticle = TestFixtures.testArticle;
    final updatedArticle = existingArticle.copyWith(title: 'Updated Title');

    test('should return DataSuccess with updated article when successful',
        () async {
      // Arrange
      when(mockRepository.updateArticle(updatedArticle))
          .thenAnswer((_) async => DataSuccess(updatedArticle));

      // Act
      final result = await useCase(params: updatedArticle);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data?.title, 'Updated Title');
      verify(mockRepository.updateArticle(updatedArticle)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DataFailed when update fails', () async {
      // Arrange
      final exception = Exception('Failed to update article');
      when(mockRepository.updateArticle(updatedArticle))
          .thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(params: updatedArticle);

      // Assert
      expect(result, isA<DataFailed>());
      verify(mockRepository.updateArticle(updatedArticle)).called(1);
    });

    test('should return DataFailed when params is null', () async {
      // Act
      final result = await useCase(params: null);

      // Assert
      expect(result, isA<DataFailed>());
      verifyNever(mockRepository.updateArticle(any));
    });

    test('should preserve article ID during update', () async {
      // Arrange
      when(mockRepository.updateArticle(updatedArticle))
          .thenAnswer((_) async => DataSuccess(updatedArticle));

      // Act
      await useCase(params: updatedArticle);

      // Assert
      final captured =
          verify(mockRepository.updateArticle(captureAny)).captured.single;
      expect(captured.id, existingArticle.id);
    });
  });
}
