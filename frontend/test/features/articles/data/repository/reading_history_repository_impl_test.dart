import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/data/data_sources/remote/article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/articles/data/data_sources/remote/reading_history_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/articles/data/models/article_model.dart';
import 'package:news_app_clean_architecture/features/articles/data/repository/reading_history_repository_impl.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';

class MockReadingHistoryRemoteDataSource extends Mock implements ReadingHistoryRemoteDataSource {}

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
  late MockReadingHistoryRemoteDataSource historyDataSource;
  late MockArticleRemoteDataSource articleDataSource;
  late ReadingHistoryRepositoryImpl repository;

  setUp(() {
    historyDataSource = MockReadingHistoryRemoteDataSource();
    articleDataSource = MockArticleRemoteDataSource();
    repository = ReadingHistoryRepositoryImpl(historyDataSource, articleDataSource);
  });

  test('returns the viewed articles in the order they were viewed, skipping deleted ones', () async {
    when(() => historyDataSource.getRecentArticleIds(10)).thenAnswer((_) async => ['b', 'deleted', 'a']);
    when(
      () => articleDataSource.getArticlesByIds(['b', 'deleted', 'a']),
    ).thenAnswer((_) async => [buildArticle('a'), buildArticle('b')]);

    final result = await repository.getRecentlyViewed(10);

    expect(result.data!.map((article) => article.id), ['b', 'a']);
  });

  test('records a view', () async {
    when(() => historyDataSource.recordView('a')).thenAnswer((_) async {});

    expect(await repository.recordView('a'), isA<DataSuccess>());
  });

  test('deletes the views beyond the given count', () async {
    when(() => historyDataSource.deleteViewsBeyond(10)).thenAnswer((_) async {});

    expect(await repository.deleteViewsBeyond(10), isA<DataSuccess>());
  });
}
