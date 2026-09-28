import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_all_user_articles.dart';

import 'get_all_user_articles_test.mocks.dart';

@GenerateMocks([UserArticleRepository])
void main() {
  late MockUserArticleRepository mockRepository;
  late GetAllUserArticles usecase;

  const tArticle = ArticleEntity(
    id: '1',
    authorDisplayName: 'Jane Doe',
    title: 'Community Post',
    urlToImage: 'https://example.com/community.jpg',
    publishedAt: '2026-09-27T00:00:00Z',
    content: 'Community content',
    authorId: 'user-456',
  );

  setUp(() {
    mockRepository = MockUserArticleRepository();
    usecase = GetAllUserArticles(mockRepository);
  });

  test('should return every user-created article', () async {
    when(mockRepository.getAllUserArticles())
        .thenAnswer((_) async => const DataSuccess([tArticle]));

    final result = await usecase();

    expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    expect(result.data, [tArticle]);
    verify(mockRepository.getAllUserArticles()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DataGenericFailed when repository fails', () async {
    when(mockRepository.getAllUserArticles()).thenAnswer(
        (_) async => const DataGenericFailed('Failed to load articles'));

    final result = await usecase();

    expect(result, isA<DataGenericFailed<List<ArticleEntity>>>());
    verify(mockRepository.getAllUserArticles()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
