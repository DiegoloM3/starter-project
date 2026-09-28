import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/article_local_mapper.dart';
import 'package:news_app_clean_architecture/features/news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';

void main() {
  group('ArticleModel', () {
    group('fromJson', () {
      test('should map all fields correctly from a full JSON map', () {
        final json = {
          'author': 'John Doe',
          'title': 'Test Title',
          'description': 'Test Description',
          'url': 'https://example.com',
          'urlToImage': 'https://example.com/image.jpg',
          'publishedAt': '2024-01-01T00:00:00Z',
          'content': 'Test Content',
        };

        final result = ArticleModel.fromJson(json);

        expect(result.authorDisplayName, 'John Doe');
        expect(result.title, 'Test Title');
        expect(result.urlToImage, 'https://example.com/image.jpg');
        expect(result.publishedAt, '2024-01-01T00:00:00Z');
        expect(result.content, 'Test Content');
      });

      test('should return null urlToImage when urlToImage is absent from JSON',
          () {
        final json = {
          'author': 'John Doe',
          'title': 'Test Title',
        };

        final result = ArticleModel.fromJson(json);

        // json_serializable maps missing keys to null (nullable fields)
        expect(result.urlToImage, isNull);
      });

      test('should return null for missing nullable fields', () {
        final json = <String, dynamic>{};

        final result = ArticleModel.fromJson(json);

        expect(result.authorDisplayName, isNull);
        expect(result.title, isNull);
        expect(result.publishedAt, isNull);
        expect(result.content, isNull);
        expect(result.urlToImage, isNull);
      });
    });

    group('ArticleLocalMapper.fromRow (Drift row)', () {
      test('should map a Drift Article row to an ArticleModel', () {
        final row = ArticlesTableData(
          id: "1",
          authorDisplayName: 'John Doe',
          title: 'Test Title',
          urlToImage: 'https://example.com/image.jpg',
          publishedAt: '2024-01-01T00:00:00Z',
          content: 'Test Content',
          authorId: null,
        );

        final result = ArticleLocalMapper.fromRow(row);

        expect(result.id, row.id);
        expect(result.authorDisplayName, row.authorDisplayName);
        expect(result.title, row.title);
        expect(result.urlToImage, row.urlToImage);
        expect(result.publishedAt, row.publishedAt);
        expect(result.content, row.content);
      });

      test('should use kDefaultImage when urlToImage is null in the row', () {
        final row = ArticlesTableData(
          id: "1",
          authorDisplayName: "unknown",
          title: "test",
          urlToImage: null,
          publishedAt: DateTime.now().toString(),
          content: "",
          authorId: null,
        );

        final result = ArticleLocalMapper.fromRow(row);

        expect(result.urlToImage, kDefaultImage);
      });
    });

    group('fromEntity', () {
      test('should copy all fields from an ArticleEntity', () {
        const entity = ArticleEntity(
          id: "1",
          authorDisplayName: 'John Doe',
          title: 'Test Title',
          urlToImage: 'https://example.com/image.jpg',
          publishedAt: '2024-01-01T00:00:00Z',
          content: 'Test Content',
        );

        final result = ArticleModel.fromEntity(entity);

        expect(result.id, entity.id);
        expect(result.authorDisplayName, entity.authorDisplayName);
        expect(result.title, entity.title);
        expect(result.urlToImage, entity.urlToImage);
        expect(result.publishedAt, entity.publishedAt);
        expect(result.content, entity.content);
      });

      test('should preserve null fields from entity', () {
        const entity = ArticleEntity(
            authorDisplayName: '', title: '', publishedAt: '', content: '');

        final result = ArticleModel.fromEntity(entity);

        expect(result.id, isNull);
        expect(result.urlToImage, isNull);
      });
    });

    group('equality (Equatable)', () {
      test('two models with identical fields should be equal', () {
        const model1 = ArticleModel(
          id: "1",
          authorDisplayName: 'John Doe',
          title: 'Test Title',
          urlToImage: 'https://example.com/image.jpg',
          publishedAt: '2024-01-01T00:00:00Z',
          content: 'Test Content',
        );
        const model2 = ArticleModel(
          id: "1",
          authorDisplayName: 'John Doe',
          title: 'Test Title',
          urlToImage: 'https://example.com/image.jpg',
          publishedAt: '2024-01-01T00:00:00Z',
          content: 'Test Content',
        );

        expect(model1, equals(model2));
      });

      test('two models with different fields should not be equal', () {
        const model1 = ArticleModel(
            id: "1",
            title: 'Title A',
            authorDisplayName: '',
            publishedAt: '',
            content: '');
        const model2 = ArticleModel(
            id: "2",
            title: 'Title B',
            authorDisplayName: '',
            publishedAt: '',
            content: '');

        expect(model1, isNot(equals(model2)));
      });
    });
    group('toJson', () {
      test('should serialize ArticleModel into a Map with author key mapped', () {
        const model = ArticleModel(
          id: '1',
          authorDisplayName: 'John Doe',
          title: 'Test Title',
          urlToImage: 'https://example.com/image.jpg',
          publishedAt: '2024-01-01T00:00:00Z',
          content: 'Test Content',
          authorId: 'author-123',
        );

        final json = model.toJson();

        expect(json['id'], '1');
        expect(json['author'], 'John Doe');
        expect(json['title'], 'Test Title');
        expect(json['urlToImage'], 'https://example.com/image.jpg');
        expect(json['publishedAt'], '2024-01-01T00:00:00Z');
        expect(json['content'], 'Test Content');
        expect(json['authorId'], 'author-123');
      });
    });

    group('copyWith', () {
      test('should return a new ArticleModel with updated fields', () {
        const model = ArticleModel(
          id: '1',
          authorDisplayName: 'John Doe',
          title: 'Test Title',
          urlToImage: 'https://example.com/image.jpg',
          publishedAt: '2024-01-01T00:00:00Z',
          content: 'Test Content',
        );

        final updated = model.copyWith(
          urlToImage: 'https://example.com/updated.jpg',
          title: 'Updated Title',
        );

        expect(updated.id, '1');
        expect(updated.title, 'Updated Title');
        expect(updated.urlToImage, 'https://example.com/updated.jpg');
        expect(updated.authorDisplayName, 'John Doe');
        expect(updated.publishedAt, '2024-01-01T00:00:00Z');
        expect(updated.content, 'Test Content');
      });
    });

    group('toEntity / fromRawData (1.3.2 / 1.3.3)', () {
      test('toEntity should return a pure ArticleEntity with same fields',
          () {
        const model = ArticleModel(
          id: '1',
          authorDisplayName: 'John Doe',
          title: 'Test Title',
          urlToImage: 'https://example.com/image.jpg',
          publishedAt: '2024-01-01T00:00:00Z',
          content: 'Test Content',
          authorId: 'author-123',
        );

        final entity = model.toEntity();

        expect(entity, isA<ArticleEntity>());
        expect(entity, isNot(isA<ArticleModel>()));
        expect(entity.id, '1');
        expect(entity.authorDisplayName, 'John Doe');
        expect(entity.authorId, 'author-123');
      });

      test('fromRawData should parse external API data like fromJson', () {
        final raw = {
          'author': 'Jane',
          'title': 'Raw Title',
          'urlToImage': 'https://example.com/raw.jpg',
          'publishedAt': '2024-02-02T00:00:00Z',
          'content': 'Raw content',
        };

        final result = ArticleModel.fromRawData(raw);

        expect(result.authorDisplayName, 'Jane');
        expect(result.title, 'Raw Title');
      });
    });
  });
}
