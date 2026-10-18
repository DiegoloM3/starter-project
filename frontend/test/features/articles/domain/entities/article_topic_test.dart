import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';

void main() {
  group('ArticleTopic', () {
    test('has the same ids as the topics allowed by the Firestore rules', () {
      final ids = ArticleTopic.values.map((topic) => topic.id).toSet();

      expect(ids, {
        'technology',
        'sports',
        'gaming',
        'politics',
        'economy',
        'science',
        'health',
        'entertainment',
        'culture',
        'world',
      });
    });

    test('is found by its id', () {
      expect(ArticleTopic.fromId('gaming'), ArticleTopic.gaming);
    });

    test('is null for an unknown id', () {
      expect(ArticleTopic.fromId('cooking'), isNull);
    });
  });
}
