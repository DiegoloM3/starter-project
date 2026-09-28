import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/save_article.dart';

import 'usecases_test.mocks.dart';

@GenerateMocks([ArticleRepository])
void main() {
  late MockArticleRepository mockRepository;

  const tArticle = ArticleEntity(
    id: "1",
    authorDisplayName: 'John Doe',
    title: 'Test Title',
    urlToImage: 'https://example.com/image.jpg',
    publishedAt: '2024-01-01T00:00:00Z',
    content: 'Test Content',
  );
  final tArticleList = [tArticle];

  setUp(() {
    mockRepository = MockArticleRepository();
  });

  // ---------------------------------------------------------------------------
  group('GetArticleUseCase', () {
    test('should call getNewsArticles on the repository and return DataSuccess',
        () async {
      when(mockRepository.getNewsArticles())
          .thenAnswer((_) async => DataSuccess(tArticleList));

      final result = await GetArticleUseCase(mockRepository)();

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, tArticleList);
      verify(mockRepository.getNewsArticles()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  // ---------------------------------------------------------------------------
  group('GetSavedArticleUseCase', () {
    test('should return the saved article list from the repository', () async {
      when(mockRepository.getSavedArticles())
          .thenAnswer((_) async => tArticleList);

      final result = await GetSavedArticleUseCase(mockRepository)();

      expect(result, tArticleList);
      verify(mockRepository.getSavedArticles()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return an empty list when no articles are saved', () async {
      when(mockRepository.getSavedArticles()).thenAnswer((_) async => []);

      final result = await GetSavedArticleUseCase(mockRepository)();

      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  group('SaveArticleUseCase', () {
    test('should call saveArticle with the given article', () async {
      when(mockRepository.saveArticle(tArticle)).thenAnswer((_) async {});

      await SaveArticleUseCase(mockRepository)(params: tArticle);

      verify(mockRepository.saveArticle(tArticle)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    // BUG FIX: params was force-unwrapped (params!) without a null guard.
    // Calling with null must not throw and must not touch the repository.
    test('should do nothing and not crash when params is null', () async {
      await SaveArticleUseCase(mockRepository)(params: null);

      verifyZeroInteractions(mockRepository);
    });
  });

  // ---------------------------------------------------------------------------
  group('RemoveArticleUseCase', () {
    test('should call removeArticle with the given article', () async {
      when(mockRepository.removeArticle(tArticle)).thenAnswer((_) async {});

      await RemoveArticleUseCase(mockRepository)(params: tArticle);

      verify(mockRepository.removeArticle(tArticle)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    // BUG FIX: same null guard as SaveArticleUseCase.
    test('should do nothing and not crash when params is null', () async {
      await RemoveArticleUseCase(mockRepository)(params: null);

      verifyZeroInteractions(mockRepository);
    });
  });
}
