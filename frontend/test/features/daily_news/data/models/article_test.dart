import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

void main() {
  const testMap = {
    'author': 'John Doe',
    'title': 'Test Article',
    'description': 'A test description',
    'url': 'https://example.com/article',
    'urlToImage': 'https://example.com/image.jpg',
    'publishedAt': '2024-01-01T00:00:00Z',
    'content': 'Full article content here.',
  };

  group('ArticleModel.fromJson', () {
    test('maps all fields from raw map', () {
      final model = ArticleModel.fromJson(testMap);

      expect(model.author, equals('John Doe'));
      expect(model.title, equals('Test Article'));
      expect(model.description, equals('A test description'));
      expect(model.url, equals('https://example.com/article'));
      expect(model.urlToImage, equals('https://example.com/image.jpg'));
      expect(model.publishedAt, equals('2024-01-01T00:00:00Z'));
      expect(model.content, equals('Full article content here.'));
    });

    test('falls back to empty string for null fields', () {
      final model = ArticleModel.fromJson(const {});

      expect(model.author, equals(''));
      expect(model.title, equals(''));
      expect(model.description, equals(''));
    });

    test('uses kDefaultImage when urlToImage is null', () {
      final model = ArticleModel.fromJson(const {'urlToImage': null});

      expect(model.urlToImage, isNotEmpty);
    });
  });

  group('ArticleModel.fromEntity', () {
    test('round-trips all fields from entity', () {
      const entity = ArticleEntity(
        id: 1,
        author: 'Jane Smith',
        title: 'Entity Article',
        description: 'Entity description',
        url: 'https://example.com',
        urlToImage: 'https://example.com/img.jpg',
        publishedAt: '2024-06-01',
        content: 'Entity content',
      );
      final model = ArticleModel.fromEntity(entity);

      expect(model.id, equals(entity.id));
      expect(model.author, equals(entity.author));
      expect(model.title, equals(entity.title));
      expect(model.description, equals(entity.description));
      expect(model.url, equals(entity.url));
      expect(model.urlToImage, equals(entity.urlToImage));
      expect(model.publishedAt, equals(entity.publishedAt));
      expect(model.content, equals(entity.content));
    });
  });

  group('ArticleModel.toEntity', () {
    test('returns ArticleEntity with all fields matching', () {
      final model = ArticleModel.fromJson(testMap);
      final entity = model.toEntity();

      expect(entity, isA<ArticleEntity>());
      expect(entity.author, equals(model.author));
      expect(entity.title, equals(model.title));
      expect(entity.description, equals(model.description));
      expect(entity.url, equals(model.url));
      expect(entity.urlToImage, equals(model.urlToImage));
      expect(entity.publishedAt, equals(model.publishedAt));
      expect(entity.content, equals(model.content));
    });

    test('fromJson().toEntity() preserves all fields end-to-end', () {
      final entity = ArticleModel.fromJson(testMap).toEntity();

      expect(entity.author, equals('John Doe'));
      expect(entity.title, equals('Test Article'));
      expect(entity.description, equals('A test description'));
      expect(entity.url, equals('https://example.com/article'));
    });

    test('two entities from same model satisfy Equatable equality', () {
      final model = ArticleModel.fromJson(testMap);
      final e1 = model.toEntity();
      final e2 = model.toEntity();

      expect(e1, equals(e2));
    });
  });
}
