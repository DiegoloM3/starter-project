import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_news_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_published_articles.dart';

class MockGetArticleUseCase extends Mock implements GetArticleUseCase {}

class MockGetPublishedArticlesUseCase extends Mock implements GetPublishedArticlesUseCase {}

void main() {
  late MockGetArticleUseCase getNewsArticles;
  late MockGetPublishedArticlesUseCase getPublishedArticles;
  late GetNewsFeedUseCase getNewsFeed;

  const olderNewsArticle = ArticleEntity(title: 'Older news', publishedAt: '2026-10-12T10:00:00Z');
  const newerNewsArticle = ArticleEntity(title: 'Newer news', publishedAt: '2026-10-14T10:00:00Z');
  final publishedArticle = PublishedArticleEntity(
    title: 'Published article',
    content: 'Content',
    thumbnailUrl: 'https://example.com/thumbnail.jpg',
    publishedAt: DateTime.utc(2026, 10, 13, 10),
  );
  final networkError = Exception('No connection');

  setUp(() {
    getNewsArticles = MockGetArticleUseCase();
    getPublishedArticles = MockGetPublishedArticlesUseCase();
    getNewsFeed = GetNewsFeedUseCase(getNewsArticles, getPublishedArticles);
  });

  void stubNewsArticles(DataState<List<ArticleEntity>> result) {
    when(() => getNewsArticles()).thenAnswer((_) async => result);
  }

  void stubPublishedArticles(DataState<List<PublishedArticleEntity>> result) {
    when(() => getPublishedArticles()).thenAnswer((_) async => result);
  }

  group('GetNewsFeedUseCase', () {
    test('combines both sources sorted from newest to oldest', () async {
      stubNewsArticles(const DataSuccess([olderNewsArticle, newerNewsArticle]));
      stubPublishedArticles(DataSuccess([publishedArticle]));

      final feed = await getNewsFeed();

      expect(feed, isA<DataSuccess<List<ArticleEntity>>>());
      expect(feed.data, [newerNewsArticle, publishedArticle, olderNewsArticle]);
    });

    test('shows the published articles when the news API fails', () async {
      stubNewsArticles(DataFailed(networkError));
      stubPublishedArticles(DataSuccess([publishedArticle]));

      final feed = await getNewsFeed();

      expect(feed.data, [publishedArticle]);
    });

    test('shows the news articles when the published articles fail', () async {
      stubNewsArticles(const DataSuccess([newerNewsArticle]));
      stubPublishedArticles(DataFailed(networkError));

      final feed = await getNewsFeed();

      expect(feed.data, [newerNewsArticle]);
    });

    test('fails when both sources fail', () async {
      stubNewsArticles(DataFailed(networkError));
      stubPublishedArticles(DataFailed(Exception('Firestore unavailable')));

      final feed = await getNewsFeed();

      expect(feed, isA<DataFailed<List<ArticleEntity>>>());
      expect(feed.error, networkError);
    });

    test('places articles without a valid publication date last', () async {
      const undatedArticle = ArticleEntity(title: 'Undated', publishedAt: '');
      stubNewsArticles(const DataSuccess([undatedArticle, olderNewsArticle]));
      stubPublishedArticles(const DataSuccess([]));

      final feed = await getNewsFeed();

      expect(feed.data, [olderNewsArticle, undatedArticle]);
    });
  });
}
