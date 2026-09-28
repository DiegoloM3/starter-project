import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_user_articles.dart';

import 'get_user_articles_test.mocks.dart';

@GenerateMocks([UserArticleRepository])
void main() {
  late MockUserArticleRepository mockRepository;
  late GetUserArticles usecase;

  const tArticle = ArticleEntity(
    id: '1',
    authorDisplayName: 'John Doe',
    title: 'Test Title',
    urlToImage: 'https://example.com/image.jpg',
    publishedAt: '2026-09-27T00:00:00Z',
    content: 'Test Content',
    authorId: 'user-123',
  );

  setUp(() {
    mockRepository = MockUserArticleRepository();
    usecase = GetUserArticles(mockRepository);
  });

  test('should return articles for the given userId', () async {
    when(mockRepository.getUserArticles('user-123'))
        .thenAnswer((_) async => const DataSuccess([tArticle]));

    final result = await usecase(
      params: const GetUserArticlesParams(userId: 'user-123'),
    );

    expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    expect(result.data, [tArticle]);
    verify(mockRepository.getUserArticles('user-123')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when params are null', () async {
    final result = await usecase();

    expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    expect(result.data, isEmpty);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DataGenericFailed when repository fails', () async {
    when(mockRepository.getUserArticles('user-123')).thenAnswer(
        (_) async => const DataGenericFailed('Failed to load articles'));

    final result = await usecase(
      params: const GetUserArticlesParams(userId: 'user-123'),
    );

    expect(result, isA<DataGenericFailed<List<ArticleEntity>>>());
    verify(mockRepository.getUserArticles('user-123')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
