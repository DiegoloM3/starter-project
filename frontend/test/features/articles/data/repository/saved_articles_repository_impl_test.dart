import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/data/data_sources/remote/article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/articles/data/data_sources/remote/saved_articles_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/articles/data/models/article_model.dart';
import 'package:news_app_clean_architecture/features/articles/data/repository/saved_articles_repository_impl.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';

class MockSavedArticlesRemoteDataSource extends Mock implements SavedArticlesRemoteDataSource {}

class MockArticleRemoteDataSource extends Mock implements ArticleRemoteDataSource {}

ArticleModel buildArticle(String id) {
  return ArticleModel(
    id: id,
    title: 'Title',
    description: 'Description',
    content: ArticleContent.fromPlainText('Content'),
    thumbnailURL: 'https://example.com/image.jpg',
    topics: const [ArticleTopic.sports],
    publishedAt: DateTime(2026, 10, 16),
    authorId: 'journalist-1',
    authorName: 'Jane Doe',
  );
}

void main() {
  late MockSavedArticlesRemoteDataSource savedDataSource;
  late MockArticleRemoteDataSource articleDataSource;
  late SavedArticlesRepositoryImpl repository;

  setUp(() {
    savedDataSource = MockSavedArticlesRemoteDataSource();
    articleDataSource = MockArticleRemoteDataSource();
    repository = SavedArticlesRepositoryImpl(savedDataSource, articleDataSource);
  });

  test('returns the saved articles in the order they were saved, skipping deleted ones', () async {
    when(() => savedDataSource.getSavedArticleIds()).thenAnswer((_) async => ['b', 'deleted', 'a']);
    when(
      () => articleDataSource.getArticlesByIds(['b', 'deleted', 'a']),
    ).thenAnswer((_) async => [buildArticle('a'), buildArticle('b')]);

    final result = await repository.getSavedArticles();

    expect(result.data!.map((article) => article.id), ['b', 'a']);
  });

  test('saves an article', () async {
    when(() => savedDataSource.saveArticle('a')).thenAnswer((_) async {});

    final result = await repository.saveArticle('a');

    expect(result, isA<DataSuccess>());
  });

  test('removes a saved article', () async {
    when(() => savedDataSource.removeSavedArticle('a')).thenAnswer((_) async {});

    final result = await repository.removeSavedArticle('a');

    expect(result, isA<DataSuccess>());
  });
}
