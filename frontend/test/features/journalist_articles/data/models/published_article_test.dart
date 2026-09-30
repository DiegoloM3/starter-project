import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';

final publishedAt = DateTime.utc(2026, 9, 28, 16, 23, 33);

Map<String, dynamic> rawArticle() {
  return {
    'id': 'uf6vZSr0ZiUAYhBkx4YN',
    'title': 'Breaking News!',
    'content': '## Subtitle\n\nThis is **breaking** news.',
    'description': 'Subtitle This is breaking news.',
    'author': 'Daily News Staff',
    'thumbnailURL': 'https://firebasestorage.googleapis.com/v0/b/bucket/o/media%2Farticles%2Fuf6vZSr0ZiUAYhBkx4YN.jpg',
    'publishedAt': publishedAt,
  };
}

void main() {
  group('fromRawData', () {
    test('reads every field of the stored document (see backend/docs/DB_SCHEMA.md)', () {
      final model = PublishedArticleModel.fromRawData(rawArticle());

      expect(model.id, 'uf6vZSr0ZiUAYhBkx4YN');
      expect(model.title, 'Breaking News!');
      expect(model.content, '## Subtitle\n\nThis is **breaking** news.');
      expect(model.description, 'Subtitle This is breaking news.');
      expect(model.author, 'Daily News Staff');
      expect(model.thumbnailUrl, endsWith('uf6vZSr0ZiUAYhBkx4YN.jpg'));
      expect(model.publishedAt, publishedAt);
    });

    for (final field in ['id', 'title', 'content', 'description', 'author', 'thumbnailURL', 'publishedAt']) {
      test('rejects a document without $field', () {
        final raw = rawArticle()..remove(field);

        expect(() => PublishedArticleModel.fromRawData(raw), throwsFormatException);
      });
    }

    test('rejects a field of the wrong type', () {
      final raw = rawArticle()..['publishedAt'] = '2026-09-28';

      expect(() => PublishedArticleModel.fromRawData(raw), throwsFormatException);
    });
  });

  test('toEntity returns a plain entity with the same fields', () {
    final entity = PublishedArticleModel.fromRawData(rawArticle()).toEntity();

    expect(entity.runtimeType, PublishedArticleEntity);
    expect(entity.title, 'Breaking News!');
    expect(entity.publishedAt, publishedAt);
  });

  test('newDocumentFields are the stored fields of a draft, except the server timestamp', () {
    const draft = ArticleDraftEntity(
      title: 'Breaking News!',
      content: '## Subtitle\n\nThis is **breaking** news.',
      author: 'Daily News Staff',
      thumbnail: ArticleThumbnailEntity(localPath: '/gallery/photo.jpg', sizeInBytes: 1024),
    );

    final fields = PublishedArticleModel.newDocumentFields(draft, 'https://example.com/photo.jpg');

    expect(fields, {
      'title': 'Breaking News!',
      'content': '## Subtitle\n\nThis is **breaking** news.',
      'description': 'Subtitle This is breaking news.',
      'author': 'Daily News Staff',
      'thumbnailURL': 'https://example.com/photo.jpg',
    });
  });
}
