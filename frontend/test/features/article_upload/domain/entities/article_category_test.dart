import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';

void main() {
  group('ArticleCategory', () {
    test('toApiValue returns lowercase string for each value', () {
      expect(ArticleCategory.fitness.toApiValue(), 'fitness');
      expect(ArticleCategory.news.toApiValue(), 'news');
      expect(ArticleCategory.lifestyle.toApiValue(), 'lifestyle');
      expect(ArticleCategory.tech.toApiValue(), 'tech');
      expect(ArticleCategory.other.toApiValue(), 'other');
    });

    test('fromApiValue round-trips all values', () {
      for (final category in ArticleCategory.values) {
        expect(
          ArticleCategory.fromApiValue(category.toApiValue()),
          category,
        );
      }
    });

    test('fromApiValue throws ArgumentError for unknown value', () {
      expect(
        () => ArticleCategory.fromApiValue('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
