import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_published_articles.dart';

import '../../../../fixtures/test_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late GetPublishedArticlesUseCase useCase;
  late MockUserArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockUserArticleRepository();
    useCase = GetPublishedArticlesUseCase(mockRepository);
  });

  group('GetPublishedArticlesUseCase', () {
    final publishedArticles = TestFixtures.publishedArticlesOnly;

    test('should return DataSuccess with list of published articles', () async {
      // Arrange
      when(mockRepository.getPublishedArticles())
          .thenAnswer((_) async => DataSuccess(publishedArticles));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, publishedArticles);
      expect(result.data?.every((a) => !a.isDraft), true);
      verify(mockRepository.getPublishedArticles()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no published articles exist', () async {
      // Arrange
      when(mockRepository.getPublishedArticles())
          .thenAnswer((_) async => DataSuccess([]));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, isEmpty);
    });

    test('should return DataFailed when repository fails', () async {
      // Arrange
      final exception = Exception('Network error');
      when(mockRepository.getPublishedArticles())
          .thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<DataFailed>());
      verify(mockRepository.getPublishedArticles()).called(1);
    });

    test('should only return articles where isDraft is false', () async {
      // Arrange
      when(mockRepository.getPublishedArticles())
          .thenAnswer((_) async => DataSuccess(publishedArticles));

      // Act
      final result = await useCase();

      // Assert
      final articles = (result as DataSuccess).data!;
      for (final article in articles) {
        expect(article.isDraft, false);
      }
    });
  });
}
