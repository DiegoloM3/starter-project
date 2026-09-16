import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

void main() {
  const fullRaw = {
    'author': ' Ada Lovelace ',
    'title': 'Engines of the future',
    'description': 'A short teaser.',
    'url': 'https://news.example/engines',
    'urlToImage': 'https://news.example/engines.jpg',
    'publishedAt': '2026-09-15T10:00:00Z',
    'content': 'Full body of the article.',
  };

  group('ArticleModel.fromRawData', () {
    test('maps every provider field onto the entity', () {
      final model = ArticleModel.fromRawData(fullRaw);

      expect(model.source, ArticleSource.remote);
      expect(model.id, 'https://news.example/engines');
      expect(model.title, 'Engines of the future');
      expect(model.description, 'A short teaser.');
      expect(model.content, 'Full body of the article.');
      expect(model.author, 'Ada Lovelace');
      expect(model.imageUrl, 'https://news.example/engines.jpg');
      expect(model.url, 'https://news.example/engines');
      expect(model.publishedAt, DateTime.utc(2026, 9, 15, 10));
      expect(model.authorId, isNull);
      expect(model.imagePath, isNull);
    });

    test('uses the title as id when the url is missing', () {
      final model = ArticleModel.fromRawData({'title': 'No link'});

      expect(model.id, 'No link');
      expect(model.url, isNull);
    });

    test('treats empty and null optional fields as absent', () {
      final model = ArticleModel.fromRawData({
        'title': 'Sparse',
        'description': '',
        'urlToImage': null,
        'author': null,
      });

      expect(model.description, isNull);
      expect(model.imageUrl, isNull);
      expect(model.hasImage, isFalse);
      expect(model.hasDescription, isFalse);
      expect(model.author, 'Unknown author');
    });

    test('falls back to the description as content when content is missing', () {
      final model = ArticleModel.fromRawData({
        'title': 'Teaser only',
        'description': 'Only a teaser was provided.',
      });

      expect(model.content, 'Only a teaser was provided.');
    });

    test('falls back to the epoch when publishedAt is missing or invalid', () {
      final missing = ArticleModel.fromRawData({'title': 'a'});
      final invalid = ArticleModel.fromRawData({'title': 'b', 'publishedAt': 'yesterday'});

      final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      expect(missing.publishedAt, epoch);
      expect(invalid.publishedAt, epoch);
    });

    test('ignores values with unexpected types', () {
      final model = ArticleModel.fromRawData({'title': 42, 'url': ['x']});

      expect(model.title, '');
      expect(model.url, isNull);
    });
  });

}
