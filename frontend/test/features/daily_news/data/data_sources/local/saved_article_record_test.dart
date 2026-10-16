import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_record.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

void main() {
  group('SavedArticleRecord', () {
    test('converts a model to a record and back without losing values', () {
      const model = ArticleModel(
        id: 1,
        author: 'Author',
        title: 'Title',
        description: 'Description',
        url: 'https://example.com',
        urlToImage: 'https://example.com/image.jpg',
        publishedAt: '2026-10-15T09:30:00Z',
        content: 'Content',
      );

      expect(SavedArticleRecord.fromModel(model).toModel(), model);
    });
  });
}
