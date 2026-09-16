import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

void main() {
  group('NewsCategory', () {
    test('fromApiValue resolves every known value', () {
      for (final category in NewsCategory.values) {
        expect(NewsCategory.fromApiValue(category.apiValue), category);
      }
    });

    test('fromApiValue falls back to general for unknown or null values', () {
      expect(NewsCategory.fromApiValue('politics'), NewsCategory.general);
      expect(NewsCategory.fromApiValue(null), NewsCategory.general);
    });

  });
}
