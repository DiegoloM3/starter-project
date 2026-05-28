import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';

void main() {
  group('ArticleStatus constants', () {
    test('has correct values', () {
      expect(ArticleStatus.draft, 'draft');
      expect(ArticleStatus.published, 'published');
      expect(ArticleStatus.archived, 'archived');
    });

    test('values contains all statuses', () {
      expect(ArticleStatus.values, containsAll(['draft', 'published', 'archived']));
      expect(ArticleStatus.values.length, 3);
    });
  });

  group('isValidTransition', () {
    test('same status is valid', () {
      expect(ArticleStatus.isValidTransition('draft', 'draft'), isTrue);
      expect(ArticleStatus.isValidTransition('published', 'published'), isTrue);
      expect(ArticleStatus.isValidTransition('archived', 'archived'), isTrue);
    });

    test('draft to published is valid', () {
      expect(ArticleStatus.isValidTransition('draft', 'published'), isTrue);
    });

    test('published to archived is valid', () {
      expect(ArticleStatus.isValidTransition('published', 'archived'), isTrue);
    });

    test('draft to archived is invalid', () {
      expect(ArticleStatus.isValidTransition('draft', 'archived'), isFalse);
    });

    test('published to draft is invalid', () {
      expect(ArticleStatus.isValidTransition('published', 'draft'), isFalse);
    });

    test('archived to published is invalid', () {
      expect(ArticleStatus.isValidTransition('archived', 'published'), isFalse);
    });

    test('archived to draft is invalid', () {
      expect(ArticleStatus.isValidTransition('archived', 'draft'), isFalse);
    });
  });
}
