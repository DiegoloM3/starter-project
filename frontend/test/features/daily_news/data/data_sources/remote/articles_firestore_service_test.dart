import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/articles_firestore_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ArticlesFirestoreService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = ArticlesFirestoreService(firestore);
  });

  Future<void> seedArticle(String articleId, DateTime publishedAt) {
    return firestore.collection('articles').doc(articleId).set({
      'title': 'Article $articleId',
      'content': 'Content',
      'thumbnailURL': 'media/articles/$articleId.jpg',
      'publishedAt': Timestamp.fromDate(publishedAt),
    });
  }

  group('ArticlesFirestoreService', () {
    test('creates a new article identifier on each call', () {
      final firstId = service.createArticleId();
      final secondId = service.createArticleId();

      expect(firstId, isNotEmpty);
      expect(firstId, isNot(secondId));
    });

    test('creates the article with the server time as publication date', () async {
      await service.createArticle('article1', {
        'title': 'Breaking News!',
        'content': 'This is breaking news!',
        'thumbnailURL': 'media/articles/article1.jpg',
      });

      final document = await firestore.collection('articles').doc('article1').get();
      expect(document.data()!['title'], 'Breaking News!');
      expect(document.data()!['thumbnailURL'], 'media/articles/article1.jpg');
      expect(document.data()!['publishedAt'], isA<Timestamp>());
    });

    test('returns the newest articles first with dates converted to DateTime', () async {
      await seedArticle('older', DateTime.utc(2026, 10, 13));
      await seedArticle('newer', DateTime.utc(2026, 10, 15));

      final articles = await service.getLatestArticles();

      expect(articles.map((article) => article['title']), ['Article newer', 'Article older']);
      expect(articles.first['publishedAt'], DateTime.utc(2026, 10, 15).toLocal());
    });

    test('returns at most the maximum number of articles', () async {
      for (var index = 0; index < ArticlesFirestoreService.maxArticlesPerRead + 1; index++) {
        await seedArticle('article$index', DateTime.utc(2026, 1, 1).add(Duration(minutes: index)));
      }

      final articles = await service.getLatestArticles();

      expect(articles.length, ArticlesFirestoreService.maxArticlesPerRead);
    });
  });
}
