import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

// Pins the equality contract for ArticleEntity. Spec 001 violation #5 fixed:
// the entity now uses native ==/hashCode and is no longer Equatable.
// Spec 003 added two new fields (firestoreId, uid) — this test pins those too.
void main() {
  group('ArticleEntity equality', () {
    const a = ArticleEntity(
      id: 1,
      author: 'a',
      title: 't',
      description: 'd',
      url: 'u',
      urlToImage: 'i',
      publishedAt: 'p',
      content: 'c',
    );

    test('two entities with the same fields are equal', () {
      const b = ArticleEntity(
        id: 1,
        author: 'a',
        title: 't',
        description: 'd',
        url: 'u',
        urlToImage: 'i',
        publishedAt: 'p',
        content: 'c',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('changing any single field breaks equality', () {
      const titleChanged = ArticleEntity(
        id: 1,
        author: 'a',
        title: 'different',
        description: 'd',
        url: 'u',
        urlToImage: 'i',
        publishedAt: 'p',
        content: 'c',
      );
      expect(a, isNot(equals(titleChanged)));
    });

    test('firestoreId is part of equality', () {
      const withFsId = ArticleEntity(
        title: 't',
        firestoreId: 'abc',
      );
      const withoutFsId = ArticleEntity(
        title: 't',
      );
      expect(withFsId, isNot(equals(withoutFsId)));
    });

    test('uid is part of equality', () {
      const withUid = ArticleEntity(
        title: 't',
        uid: 'user-1',
      );
      const withDifferentUid = ArticleEntity(
        title: 't',
        uid: 'user-2',
      );
      expect(withUid, isNot(equals(withDifferentUid)));
    });

    test('identical entities short-circuit', () {
      // Covers the `identical(this, other)` branch.
      expect(a == a, isTrue);
    });
  });
}
