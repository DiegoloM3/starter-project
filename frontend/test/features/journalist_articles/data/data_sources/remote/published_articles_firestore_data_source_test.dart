import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/published_articles_firestore_data_source.dart';

Map<String, Object> articleFields(String title) {
  return {
    'title': title,
    'content': 'Content of $title',
    'description': 'Content of $title',
    'author': 'Author',
    'thumbnailURL': 'https://example.com/$title.jpg',
  };
}

void main() {
  late FakeFirebaseFirestore firestore;
  late PublishedArticlesFirestoreDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = PublishedArticlesFirestoreDataSource(firestore);
  });

  Future<void> storeArticle(String id, DateTime publishedAt) {
    return firestore.collection('articles').doc(id).set({
      ...articleFields(id),
      'publishedAt': Timestamp.fromDate(publishedAt),
    });
  }

  test('generates Firestore-style ids locally', () {
    expect(dataSource.newArticleId(), matches(RegExp(r'^[A-Za-z0-9]{20}$')));
  });

  group('createArticle', () {
    test('stores the fields in articles/{articleId} with a server timestamp', () async {
      await dataSource.createArticle('article1', articleFields('Breaking News'));

      final stored = (await firestore.collection('articles').doc('article1').get()).data()!;
      expect(stored, containsPair('title', 'Breaking News'));
      expect(stored, containsPair('thumbnailURL', 'https://example.com/Breaking News.jpg'));
      expect(stored['publishedAt'], isA<Timestamp>());
      expect(stored.keys, hasLength(6));
    });
  });

  group('getArticles', () {
    setUp(() async {
      await storeArticle('oldest', DateTime.utc(2026, 9, 1));
      await storeArticle('newest', DateTime.utc(2026, 9, 3));
      await storeArticle('middle', DateTime.utc(2026, 9, 2));
    });

    test('returns models with the document id and publishedAt as a DateTime, newest first', () async {
      final articles = await dataSource.getArticles(limit: 10);

      expect(articles.map((article) => article.id), ['newest', 'middle', 'oldest']);
      expect(articles.first.publishedAt, DateTime.utc(2026, 9, 3));
      expect(articles.first.title, 'newest');
    });

    test('returns at most limit articles', () async {
      final articles = await dataSource.getArticles(limit: 2);

      expect(articles.map((article) => article.id), ['newest', 'middle']);
    });

    test('continues after the given article', () async {
      final articles = await dataSource.getArticles(limit: 10, startAfterArticleId: 'newest');

      expect(articles.map((article) => article.id), ['middle', 'oldest']);
    });
  });
}
