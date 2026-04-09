import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

// Pins spec 001 fixes for the model layer:
// - violation #1: ArticleModel exposes toEntity()
// - violation #2: the JSON constructor is fromRawData (not fromJson)
void main() {
  group('ArticleModel.fromRawData', () {
    test('parses every field from a NewsAPI-shaped map', () {
      final model = ArticleModel.fromRawData({
        'author': 'Jane',
        'title': 'Hello',
        'description': 'World',
        'url': 'https://example.com',
        'urlToImage': 'https://example.com/img.png',
        'publishedAt': '2026-04-08T00:00:00Z',
        'content': 'body',
      });

      expect(model.author, 'Jane');
      expect(model.title, 'Hello');
      expect(model.description, 'World');
      expect(model.url, 'https://example.com');
      expect(model.urlToImage, 'https://example.com/img.png');
      expect(model.publishedAt, '2026-04-08T00:00:00Z');
      expect(model.content, 'body');
    });

    test('fills missing string fields with empty string', () {
      final model = ArticleModel.fromRawData({});
      expect(model.author, '');
      expect(model.title, '');
      expect(model.description, '');
      expect(model.url, '');
      expect(model.publishedAt, '');
      expect(model.content, '');
    });

    // Pins spec 009 v1.1.0: we no longer substitute a fake default image
    // when urlToImage is missing or empty. The field stays null so the
    // presentation layer can render a real placeholder instead of asking
    // the network layer to download a non-image URL.
    test('preserves null urlToImage when NewsAPI returns null', () {
      final model = ArticleModel.fromRawData({'urlToImage': null});
      expect(model.urlToImage, isNull);
    });

    test('preserves null urlToImage when the field is missing entirely', () {
      final model = ArticleModel.fromRawData({});
      expect(model.urlToImage, isNull);
    });

    test('preserves null urlToImage when NewsAPI returns an empty string', () {
      final model = ArticleModel.fromRawData({'urlToImage': ''});
      expect(model.urlToImage, isNull);
    });

    test('keeps a real urlToImage when one is provided', () {
      final model = ArticleModel.fromRawData({
        'urlToImage': 'https://example.com/real.png',
      });
      expect(model.urlToImage, 'https://example.com/real.png');
    });
  });

  group('ArticleModel.toEntity', () {
    test('returns an ArticleEntity with the same field values', () {
      const model = ArticleModel(
        id: 7,
        author: 'a',
        title: 't',
        description: 'd',
        url: 'u',
        urlToImage: 'i',
        publishedAt: 'p',
        content: 'c',
      );

      final entity = model.toEntity();

      expect(entity, isA<ArticleEntity>());
      expect(entity.id, 7);
      expect(entity.author, 'a');
      expect(entity.title, 't');
      expect(entity.description, 'd');
      expect(entity.url, 'u');
      expect(entity.urlToImage, 'i');
      expect(entity.publishedAt, 'p');
      expect(entity.content, 'c');
    });
  });

  group('ArticleModel.fromEntity', () {
    test('round-trips an entity through the model', () {
      const entity = ArticleEntity(
        id: 9,
        author: 'a',
        title: 't',
        description: 'd',
        url: 'u',
        urlToImage: 'i',
        publishedAt: 'p',
        content: 'c',
      );

      final model = ArticleModel.fromEntity(entity);
      final back = model.toEntity();

      expect(back, equals(entity));
    });
  });
}
