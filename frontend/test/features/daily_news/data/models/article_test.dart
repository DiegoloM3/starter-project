import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

void main() {
  group('fromJson', () {
    test('keeps the image of a NewsAPI article', () {
      final article = ArticleModel.fromJson(const {'title': 'T', 'urlToImage': 'https://example.com/1.jpg'});

      expect(article.urlToImage, 'https://example.com/1.jpg');
    });

    test('has no image when NewsAPI sends none, instead of a URL that is not an image', () {
      expect(ArticleModel.fromJson(const {'title': 'T'}).urlToImage, isNull);
      expect(ArticleModel.fromJson(const {'title': 'T', 'urlToImage': ''}).urlToImage, isNull);
    });

    test('fills the missing texts with empty strings', () {
      final article = ArticleModel.fromJson(const {});

      expect([article.title, article.description, article.author, article.content], everyElement(''));
    });
  });
}
