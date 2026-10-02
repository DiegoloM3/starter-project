import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/journalist_article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/saved_journalist_article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/signed_in_journalist.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/saved_journalist_article_repository_impl.dart';

class MockSavedJournalistArticleRemoteDataSource extends Mock implements SavedJournalistArticleRemoteDataSource {}

class MockJournalistArticleRemoteDataSource extends Mock implements JournalistArticleRemoteDataSource {}

void main() {
  late MockSavedJournalistArticleRemoteDataSource savedDataSource;
  late MockJournalistArticleRemoteDataSource articleDataSource;
  late SavedJournalistArticleRepositoryImpl repository;

  JournalistArticleModel buildArticle(String id) {
    return JournalistArticleModel(
      id: id,
      title: 'Article $id',
      description: 'A description',
      content: 'Some content',
      author: 'Jane Doe',
      authorId: 'janeDoeUid',
      thumbnailURL: 'https://example.com/$id.png',
      publishedAt: DateTime.utc(2026, 9, 30),
      commentCount: 2,
    );
  }

  setUp(() {
    savedDataSource = MockSavedJournalistArticleRemoteDataSource();
    articleDataSource = MockJournalistArticleRemoteDataSource();
    repository = SavedJournalistArticleRepositoryImpl(savedDataSource, articleDataSource);
  });

  test('reads the saved articles in the order of the list, as entities', () async {
    when(() => savedDataSource.getSavedArticleIds()).thenAnswer((_) async => ['article2', 'article1']);
    when(() => articleDataSource.getArticles(['article2', 'article1']))
        .thenAnswer((_) async => [buildArticle('article2'), buildArticle('article1')]);

    final dataState = await repository.getSavedArticles();

    expect(dataState.data!.map((article) => article.id), ['article2', 'article1']);
    expect(dataState.data!.first, isNot(isA<JournalistArticleModel>()));
  });

  test('returns a failure when nobody is signed in', () async {
    when(() => savedDataSource.getSavedArticleIds()).thenThrow(const NoSignedInJournalistException());

    final dataState = await repository.getSavedArticles();

    expect(dataState.error, isA<NoSignedInJournalistException>());
  });

  test('tells whether an article is saved', () async {
    when(() => savedDataSource.isArticleSaved('article1')).thenAnswer((_) async => true);

    expect((await repository.isArticleSaved('article1')).data, isTrue);
  });

  test('saves and removes an article', () async {
    when(() => savedDataSource.saveArticle('article1')).thenAnswer((_) async {});
    when(() => savedDataSource.removeSavedArticle('article1')).thenAnswer((_) async {});

    expect(await repository.saveArticle('article1'), isA<DataSuccess>());
    expect(await repository.removeSavedArticle('article1'), isA<DataSuccess>());
  });

  test('returns the exception thrown when saving as a failure', () async {
    final error = Exception('Permission denied');
    when(() => savedDataSource.saveArticle('article1')).thenThrow(error);

    expect((await repository.saveArticle('article1')).error, error);
  });
}
