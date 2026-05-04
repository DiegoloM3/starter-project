import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/saved_articles_service_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

ArticleEntity _article({
  String url = 'https://example.com/a-1',
  String title = 'Article 1',
  String? author,
  String? description,
  String? urlToImage,
  String? publishedAt,
  String? content,
}) {
  return ArticleEntity(
    author: author ?? 'A',
    title: title,
    description: description ?? 'D',
    url: url,
    urlToImage: urlToImage ?? 'https://img/i.jpg',
    publishedAt: publishedAt ?? '2026-05-03T10:00:00Z',
    content: content ?? 'C',
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late SavedArticlesServiceImpl service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = SavedArticlesServiceImpl(firestore);
  });

  group('articleIdFor', () {
    test('returns the same id for the same URL', () {
      final id1 = SavedArticlesServiceImpl.articleIdFor(
          _article(url: 'https://example.com/a'));
      final id2 = SavedArticlesServiceImpl.articleIdFor(
          _article(url: 'https://example.com/a', title: 'different title'));
      expect(id1, id2);
    });

    test('returns different ids for different URLs', () {
      final id1 = SavedArticlesServiceImpl.articleIdFor(
          _article(url: 'https://example.com/a'));
      final id2 = SavedArticlesServiceImpl.articleIdFor(
          _article(url: 'https://example.com/b'));
      expect(id1, isNot(id2));
    });

    test('produces a 40-char hex digest', () {
      final id = SavedArticlesServiceImpl.articleIdFor(_article());
      expect(id.length, 40);
      expect(RegExp(r'^[0-9a-f]{40}$').hasMatch(id), isTrue);
    });
  });

  group('saveArticle', () {
    test('writes to users/{uid}/savedArticles/{articleId}', () async {
      const uid = 'u-1';
      final article = _article(url: 'https://example.com/cool-article');

      await service.saveArticle(uid, article);

      final id = SavedArticlesServiceImpl.articleIdFor(article);
      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('savedArticles')
          .doc(id)
          .get();

      expect(doc.exists, isTrue);
      final data = doc.data()!;
      expect(data['source'], 'newsapi');
      expect(data['url'], 'https://example.com/cool-article');
      expect(data['title'], 'Article 1');
      expect(data['savedAt'], isNotNull);
    });

    test('saving the same article twice writes to the same doc (idempotent)',
        () async {
      const uid = 'u-1';
      final article = _article();

      await service.saveArticle(uid, article);
      await service.saveArticle(uid, article);

      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('savedArticles')
          .get();

      expect(snapshot.docs, hasLength(1));
    });

    test('different users have isolated savedArticles subcollections',
        () async {
      final article = _article();

      await service.saveArticle('alice', article);
      await service.saveArticle('bob', article);

      final aliceSnap = await firestore
          .collection('users')
          .doc('alice')
          .collection('savedArticles')
          .get();
      final bobSnap = await firestore
          .collection('users')
          .doc('bob')
          .collection('savedArticles')
          .get();

      expect(aliceSnap.docs, hasLength(1));
      expect(bobSnap.docs, hasLength(1));
    });
  });

  group('getSavedArticles', () {
    test('returns articles for the given uid', () async {
      const uid = 'u-1';
      final a1 = _article(url: 'https://example.com/a-1', title: 'First');
      final a2 = _article(url: 'https://example.com/a-2', title: 'Second');

      await service.saveArticle(uid, a1);
      await service.saveArticle(uid, a2);

      final articles = await service.getSavedArticles(uid);
      expect(articles, hasLength(2));
      expect(
        articles.map((a) => a.title).toSet(),
        {'First', 'Second'},
      );
    });

    test('returns an empty list when the user has no saves', () async {
      final articles = await service.getSavedArticles('nobody');
      expect(articles, isEmpty);
    });

    test('does not leak articles from other users', () async {
      await service.saveArticle('alice', _article(url: 'https://e.com/a'));

      final bobArticles = await service.getSavedArticles('bob');
      expect(bobArticles, isEmpty);
    });
  });

  group('isSaved', () {
    test('returns true after the article was saved', () async {
      const uid = 'u-1';
      final article = _article();

      await service.saveArticle(uid, article);

      expect(await service.isSaved(uid, article), isTrue);
    });

    test('returns false for an article that has not been saved', () async {
      expect(await service.isSaved('u-1', _article()), isFalse);
    });

    test('returns false after the article has been removed', () async {
      const uid = 'u-1';
      final article = _article();

      await service.saveArticle(uid, article);
      await service.removeArticle(uid, article);

      expect(await service.isSaved(uid, article), isFalse);
    });

    test('does not leak across users', () async {
      final article = _article();
      await service.saveArticle('alice', article);

      expect(await service.isSaved('alice', article), isTrue);
      expect(await service.isSaved('bob', article), isFalse);
    });
  });

  group('removeArticle', () {
    test('deletes the article doc for the given uid', () async {
      const uid = 'u-1';
      final article = _article();

      await service.saveArticle(uid, article);
      await service.removeArticle(uid, article);

      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('savedArticles')
          .get();

      expect(snapshot.docs, isEmpty);
    });

    test('removing a non-existent article is a no-op', () async {
      // No throw expected.
      await service.removeArticle('u-1', _article());
    });

    test('only affects the calling user, not others', () async {
      final article = _article();
      await service.saveArticle('alice', article);
      await service.saveArticle('bob', article);

      await service.removeArticle('alice', article);

      final aliceSnap = await firestore
          .collection('users')
          .doc('alice')
          .collection('savedArticles')
          .get();
      final bobSnap = await firestore
          .collection('users')
          .doc('bob')
          .collection('savedArticles')
          .get();

      expect(aliceSnap.docs, isEmpty);
      expect(bobSnap.docs, hasLength(1));
    });
  });
}
