import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/create_article.dart';

import '../../../../fixtures/test_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late CreateArticleUseCase useCase;
  late MockUserArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockUserArticleRepository();
    useCase = CreateArticleUseCase(mockRepository);
  });

  group('CreateArticleUseCase', () {
    final newArticle = TestFixtures.newArticle;
    final createdArticle = TestFixtures.testDraftArticle;

    test('should return DataSuccess with article when creation is successful',
        () async {
      // Arrange
      when(mockRepository.createArticle(newArticle))
          .thenAnswer((_) async => DataSuccess(createdArticle));

      // Act
      final result = await useCase(params: newArticle);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, createdArticle);
      verify(mockRepository.createArticle(newArticle)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DataFailed when creation fails', () async {
      // Arrange
      final exception = Exception('Failed to create article');
      when(mockRepository.createArticle(newArticle))
          .thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(params: newArticle);

      // Assert
      expect(result, isA<DataFailed>());
      verify(mockRepository.createArticle(newArticle)).called(1);
    });

    test('should return DataFailed when params is null', () async {
      // Act
      final result = await useCase(params: null);

      // Assert
      expect(result, isA<DataFailed>());
      verifyNever(mockRepository.createArticle(any));
    });

    test('should pass article entity correctly to repository', () async {
      // Arrange
      when(mockRepository.createArticle(newArticle))
          .thenAnswer((_) async => DataSuccess(createdArticle));

      // Act
      await useCase(params: newArticle);

      // Assert
      final captured =
          verify(mockRepository.createArticle(captureAny)).captured.single;
      expect(captured.title, newArticle.title);
      expect(captured.authorId, newArticle.authorId);
      expect(captured.isDraft, true);
    });
  });
}
