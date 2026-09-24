import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

void main() {
  /// The enum values are sent to the News API verbatim, so a rename here is a
  /// change to the request — not a cosmetic one.
  test('every section is spelled the way the API expects it', () {
    expect(NewsCategory.general.query, 'general');
    expect(NewsCategory.entertainment.query, 'entertainment');

    for (final category in NewsCategory.values) {
      expect(category.query, category.name);
      expect(category.query, matches(RegExp(r'^[a-z]+$')));
    }
  });

  test('general leads, so it is what an unfiltered feed asks for', () {
    expect(NewsCategory.values.first, NewsCategory.general);
  });
}
