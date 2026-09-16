import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/converters/news_category_converter.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

void main() {
  final converter = NewsCategoryConverter();

  test('round-trips every category by its api value', () {
    for (final category in NewsCategory.values) {
      expect(converter.encode(category), category.apiValue);
      expect(converter.decode(converter.encode(category)), category);
    }
  });

  test('falls back to general for unknown values', () {
    expect(converter.decode('politics'), NewsCategory.general);
  });
}
