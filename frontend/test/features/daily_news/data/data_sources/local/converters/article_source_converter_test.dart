import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/converters/article_source_converter.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

void main() {
  final converter = ArticleSourceConverter();

  test('round-trips every source by name', () {
    for (final source in ArticleSource.values) {
      expect(converter.decode(converter.encode(source)), source);
    }
  });

  test('falls back to remote for unknown values', () {
    expect(converter.decode('legacy'), ArticleSource.remote);
  });
}
