import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('ArticleEntity', () {
    test('hasImage is false for a null or blank url', () {
      expect(buildArticle(imageUrl: null).hasImage, isFalse);
      expect(buildArticle(imageUrl: '   ').hasImage, isFalse);
      expect(buildArticle().hasImage, isTrue);
    });

    test('hasDescription is false for a null or blank summary', () {
      expect(buildArticle(description: null).hasDescription, isFalse);
      expect(buildArticle(description: '').hasDescription, isFalse);
      expect(buildArticle().hasDescription, isTrue);
    });

    test('isUserArticle reflects the source', () {
      expect(buildArticle().isUserArticle, isFalse);
      expect(buildUserArticle().isUserArticle, isTrue);
    });

    group('isOwnedBy', () {
      test('is true only for the matching author id', () {
        final article = buildUserArticle(authorId: 'uid-1');
        expect(article.isOwnedBy('uid-1'), isTrue);
        expect(article.isOwnedBy('uid-2'), isFalse);
      });

      test('is false when either side has no id', () {
        expect(buildUserArticle(authorId: 'uid-1').isOwnedBy(null), isFalse);
        expect(buildArticle(authorId: null).isOwnedBy('uid-1'), isFalse);
      });
    });

    group('readingTimeMinutes', () {
      test('is never below one minute', () {
        expect(buildArticle(content: '').readingTimeMinutes, 1);
        expect(buildArticle(content: 'Three short words.').readingTimeMinutes, 1);
      });

      test('rounds up at the reading speed', () {
        final words = List.filled(ArticleEntity.wordsPerMinute * 2 + 1, 'word').join(' ');
        expect(buildArticle(content: words).readingTimeMinutes, 3);
      });

      test('ignores runs of whitespace', () {
        expect(buildArticle(content: 'a   b\n\nc').readingTimeMinutes, 1);
      });
    });

  });
}
