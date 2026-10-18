import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_for_you_articles.dart';

import 'article_test_data.dart';

ArticleEntity articleBy(String authorId, String id) {
  return ArticleEntity(
    id: id,
    title: testArticle.title,
    description: testArticle.description,
    content: testArticle.content,
    thumbnailURL: testArticle.thumbnailURL,
    topics: testArticle.topics,
    publishedAt: testArticle.publishedAt,
    authorId: authorId,
    authorName: testArticle.authorName,
  );
}

void main() {
  late MockArticleRepository repository;
  final followedAuthorArticle = articleBy('followed-author', 'article-1');
  final otherAuthorArticle = articleBy('other-author', 'article-2');

  setUp(() => repository = MockArticleRepository());

  test('returns the latest articles except those of the followed authors', () async {
    when(
      () => repository.getArticles(),
    ).thenAnswer((_) async => DataSuccess([followedAuthorArticle, otherAuthorArticle]));

    final result = await GetForYouArticlesUseCase(repository).call(const ['followed-author']);

    expect(result.data, [otherAuthorArticle]);
  });

  test('returns every article when the user follows nobody', () async {
    when(
      () => repository.getArticles(),
    ).thenAnswer((_) async => DataSuccess([followedAuthorArticle, otherAuthorArticle]));

    final result = await GetForYouArticlesUseCase(repository).call(const []);

    expect(result.data, [followedAuthorArticle, otherAuthorArticle]);
  });

  test('fails with the error of the repository', () async {
    final error = Exception('offline');
    when(() => repository.getArticles()).thenAnswer((_) async => DataFailed(error));

    final result = await GetForYouArticlesUseCase(repository).call(const []);

    expect(result.error, error);
  });
}
