import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/published_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/published_article.dart';

void main() {
  final publishedAt = DateTime.utc(2026, 10, 15, 9, 30);

  group('PublishedArticleModel', () {
    test('is built from the raw data of an articles document', () {
      final model = PublishedArticleModel.fromRawData(
        {
          'title': 'Breaking News!',
          'content': 'This is breaking news!',
          'thumbnailURL': 'media/articles/article1.jpg',
          'publishedAt': publishedAt,
        },
        thumbnailUrl: 'https://example.com/article1.jpg',
      );

      expect(model.title, 'Breaking News!');
      expect(model.content, 'This is breaking news!');
      expect(model.urlToImage, 'https://example.com/article1.jpg');
      expect(model.publishedAt, '2026-10-15T09:30:00Z');
    });

    test('converts to an entity with the same values', () {
      final model = PublishedArticleModel(
        title: 'Breaking News!',
        content: 'This is breaking news!',
        thumbnailUrl: 'https://example.com/article1.jpg',
        publishedAt: publishedAt,
      );

      final entity = model.toEntity();

      expect(entity, isNot(isA<PublishedArticleModel>()));
      expect(entity, PublishedArticleEntity(
        title: 'Breaking News!',
        content: 'This is breaking news!',
        thumbnailUrl: 'https://example.com/article1.jpg',
        publishedAt: publishedAt,
      ));
    });

    test('builds the raw data of a new article from a draft', () {
      const draft = ArticleDraftEntity(
        title: 'Breaking News!',
        content: 'This is breaking news!',
        thumbnailPath: '/local/image.jpg',
      );

      final rawData = PublishedArticleModel.toRawData(draft, thumbnailPath: 'media/articles/article1.jpg');

      expect(rawData, {
        'title': 'Breaking News!',
        'content': 'This is breaking news!',
        'thumbnailURL': 'media/articles/article1.jpg',
      });
    });
  });
}
