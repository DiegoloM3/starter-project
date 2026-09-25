import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

void main() {
  test('cleans what NewsAPI adds to the text', () {
    final model = ArticleModel.fromRawData({
      'source': {'id': 'bbc-news', 'name': 'BBC News'},
      'title': 'Storm hits the coast - BBC News',
      'content': 'Heavy rain fell overnight across the region [+2345 chars]',
    });

    expect(model.title, 'Storm hits the coast');
    expect(model.content, 'Heavy rain fell overnight across the region');
    expect(model.sourceName, 'BBC News');
  });

  test('also removes a shortened source name from the title', () {
    final model = ArticleModel.fromRawData({
      'source': {'name': 'BBC News'},
      'title': 'US judge blocks deportation - BBC',
    });

    expect(model.title, 'US judge blocks deportation');
  });

  test('leaves a title alone when it does not end in its source', () {
    final model = ArticleModel.fromRawData({
      'source': {'name': 'Reuters'},
      'title': 'Markets rally - analysts react',
    });

    expect(model.title, 'Markets rally - analysts react');
  });

  test('has an empty image url when the story has no image', () {
    final model = ArticleModel.fromRawData({'urlToImage': null});

    expect(model.urlToImage, isEmpty);
  });
}
