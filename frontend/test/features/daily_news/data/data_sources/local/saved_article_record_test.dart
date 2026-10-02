import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_record.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

void main() {
  const model = ArticleModel(
    id: 7,
    author: 'Jane Doe',
    title: 'Steelers trade Joey Porter Jr. to the Cowboys',
    description: 'The cornerback moves to Dallas.',
    url: 'https://example.com/steelers',
    urlToImage: 'https://example.com/steelers.jpg',
    publishedAt: '2026-10-01T03:55:00Z',
    content: 'The Steelers traded their cornerback on Tuesday.',
  );

  test('a saved article is read back with the same fields', () {
    expect(SavedArticleRecord.fromModel(model).toModel(), model);
  });
}
