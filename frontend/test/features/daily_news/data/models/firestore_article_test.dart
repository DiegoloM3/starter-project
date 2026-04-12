import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/firestore_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';

void main() {
  group('FirestoreArticleModel', () {
    group('fromRawData', () {
      test('parses all fields correctly', () {
        final data = {
          'title': 'Test Title',
          'author': 'Test Author',
          'body': 'Test body content',
          'description': 'A description',
          'section': 'deportes',
          'images': ['url1.jpg', 'url2.jpg'],
          'userId': 'user-123',
          'createdAt': DateTime(2025, 1, 15),
        };

        final model = FirestoreArticleModel.fromRawData(data, 'doc-abc');

        expect(model.documentId, 'doc-abc');
        expect(model.title, 'Test Title');
        expect(model.author, 'Test Author');
        expect(model.content, 'Test body content');
        expect(model.description, 'A description');
        expect(model.section, NewsSection.sports);
        expect(model.images, ['url1.jpg', 'url2.jpg']);
        expect(model.userId, 'user-123');
        expect(model.publishedAt, DateTime(2025, 1, 15).toIso8601String());
      });

      test('maps section strings to enums correctly', () {
        final sections = {
          'politica': NewsSection.politics,
          'clima': NewsSection.weather,
          'deportes': NewsSection.sports,
          'artes': NewsSection.arts,
          'policiaca': NewsSection.crime,
        };

        for (final entry in sections.entries) {
          final model = FirestoreArticleModel.fromRawData(
            {'title': '', 'author': '', 'body': '', 'section': entry.key},
            'doc',
          );
          expect(model.section, entry.value,
              reason: '${entry.key} should map to ${entry.value}');
        }
      });

      test('handles missing optional fields', () {
        final data = {
          'title': 'Title',
          'author': 'Author',
          'body': 'Body',
          'section': 'artes',
        };

        final model = FirestoreArticleModel.fromRawData(data, 'doc-1');

        expect(model.description, isNull);
        expect(model.images, isEmpty);
        expect(model.userId, isNull);
        expect(model.publishedAt, isNull);
      });

      test('handles null section gracefully', () {
        final data = {
          'title': 'Title',
          'author': 'Author',
          'body': 'Body',
          'section': null,
        };

        final model = FirestoreArticleModel.fromRawData(data, 'doc-1');

        expect(model.section, isNull);
      });

      test('handles String createdAt', () {
        final data = {
          'title': '',
          'author': '',
          'body': '',
          'section': 'artes',
          'createdAt': '2025-06-01T12:00:00.000',
        };

        final model = FirestoreArticleModel.fromRawData(data, 'doc');

        expect(model.publishedAt, '2025-06-01T12:00:00.000');
      });
    });

    group('fromEntity', () {
      test('copies all fields from entity', () {
        const entity = ArticleEntity(
          documentId: 'doc-1',
          title: 'Title',
          author: 'Author',
          description: 'Desc',
          content: 'Content',
          section: NewsSection.politics,
          images: ['img1.jpg'],
          userId: 'user-1',
          publishedAt: '2025-01-01',
        );

        final model = FirestoreArticleModel.fromEntity(entity);

        expect(model.documentId, 'doc-1');
        expect(model.title, 'Title');
        expect(model.author, 'Author');
        expect(model.description, 'Desc');
        expect(model.content, 'Content');
        expect(model.section, NewsSection.politics);
        expect(model.images, ['img1.jpg']);
        expect(model.userId, 'user-1');
        expect(model.publishedAt, '2025-01-01');
      });
    });

    group('toEntity', () {
      test('converts model to entity preserving all fields', () {
        const model = FirestoreArticleModel(
          documentId: 'doc-1',
          title: 'Title',
          author: 'Author',
          description: 'Desc',
          content: 'Content',
          section: NewsSection.weather,
          images: ['img.jpg'],
          userId: 'user-1',
          publishedAt: '2025-03-15',
        );

        final entity = model.toEntity();

        expect(entity, isA<ArticleEntity>());
        expect(entity.documentId, 'doc-1');
        expect(entity.title, 'Title');
        expect(entity.author, 'Author');
        expect(entity.description, 'Desc');
        expect(entity.content, 'Content');
        expect(entity.section, NewsSection.weather);
        expect(entity.images, ['img.jpg']);
        expect(entity.userId, 'user-1');
        expect(entity.publishedAt, '2025-03-15');
      });
    });

    group('toFirestoreMap', () {
      test('maps entity fields to Firestore field names', () {
        const model = FirestoreArticleModel(
          title: 'Title',
          author: 'Author',
          content: 'Body content',
          section: NewsSection.sports,
          description: 'A desc',
          images: ['img1.jpg', 'img2.jpg'],
          userId: 'user-1',
        );

        final map = model.toFirestoreMap();

        expect(map['title'], 'Title');
        expect(map['author'], 'Author');
        expect(map['body'], 'Body content');
        expect(map['section'], 'deportes');
        expect(map['description'], 'A desc');
        expect(map['images'], ['img1.jpg', 'img2.jpg']);
        expect(map['userId'], 'user-1');
      });

      test('maps all sections to Spanish values', () {
        final sectionMap = {
          NewsSection.politics: 'politica',
          NewsSection.weather: 'clima',
          NewsSection.sports: 'deportes',
          NewsSection.arts: 'artes',
          NewsSection.crime: 'policiaca',
        };

        for (final entry in sectionMap.entries) {
          final model = FirestoreArticleModel(
            title: '',
            author: '',
            content: '',
            section: entry.key,
          );
          expect(model.toFirestoreMap()['section'], entry.value);
        }
      });

      test('excludes createdAt', () {
        const model = FirestoreArticleModel(
          title: 'Title',
          author: 'Author',
          content: 'Content',
          section: NewsSection.arts,
        );

        final map = model.toFirestoreMap();

        expect(map.containsKey('createdAt'), false);
      });

      test('excludes optional fields when empty or null', () {
        const model = FirestoreArticleModel(
          title: 'Title',
          author: 'Author',
          content: 'Content',
          section: NewsSection.arts,
        );

        final map = model.toFirestoreMap();

        expect(map.containsKey('description'), false);
        expect(map.containsKey('images'), false);
        expect(map.containsKey('userId'), false);
      });

      test('includes optional fields when present', () {
        const model = FirestoreArticleModel(
          title: 'Title',
          author: 'Author',
          content: 'Content',
          section: NewsSection.arts,
          description: 'Desc',
          images: ['img.jpg'],
          userId: 'user-1',
        );

        final map = model.toFirestoreMap();

        expect(map['description'], 'Desc');
        expect(map['images'], ['img.jpg']);
        expect(map['userId'], 'user-1');
      });
    });
  });
}
