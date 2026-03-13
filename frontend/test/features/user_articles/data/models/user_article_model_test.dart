import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/models/user_article_model.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';

void main() {
  group('UserArticleModel', () {
    final testCreatedAt = DateTime(2024, 1, 1, 12, 0, 0);
    final testUpdatedAt = DateTime(2024, 1, 2, 12, 0, 0);
    final testPublishedAt = DateTime(2024, 1, 3, 12, 0, 0);

    final testArticleModel = UserArticleModel(
      id: 'article123',
      title: 'Test Article',
      description: 'Test description',
      content: 'This is test content.',
      authorId: 'user123',
      authorName: 'Test Author',
      thumbnailUrl: 'https://example.com/cover.jpg',
      categories: ['tech', 'news'],
      isDraft: false,
      createdAt: testCreatedAt,
      updatedAt: testUpdatedAt,
      publishedAt: testPublishedAt,
    );

    final testJson = {
      'id': 'article123',
      'title': 'Test Article',
      'description': 'Test description',
      'content': 'This is test content.',
      'authorId': 'user123',
      'authorName': 'Test Author',
      'thumbnailUrl': 'https://example.com/cover.jpg',
      'categories': ['tech', 'news'],
      'isDraft': false,
      'createdAt': Timestamp.fromDate(testCreatedAt),
      'updatedAt': Timestamp.fromDate(testUpdatedAt),
      'publishedAt': Timestamp.fromDate(testPublishedAt),
    };

    group('fromJson', () {
      test('should create UserArticleModel from JSON with Timestamp dates', () {
        // Act
        final result = UserArticleModel.fromJson(testJson);

        // Assert
        expect(result.id, 'article123');
        expect(result.title, 'Test Article');
        expect(result.description, 'Test description');
        expect(result.content, 'This is test content.');
        expect(result.authorId, 'user123');
        expect(result.authorName, 'Test Author');
        expect(result.thumbnailUrl, 'https://example.com/cover.jpg');
        expect(result.categories, ['tech', 'news']);
        expect(result.isDraft, false);
        expect(result.createdAt, testCreatedAt);
        expect(result.updatedAt, testUpdatedAt);
        expect(result.publishedAt, testPublishedAt);
      });

      test('should create UserArticleModel from JSON with String dates', () {
        // Arrange
        final jsonWithStringDates = {
          ...testJson,
          'createdAt': testCreatedAt.toIso8601String(),
          'updatedAt': testUpdatedAt.toIso8601String(),
          'publishedAt': testPublishedAt.toIso8601String(),
        };

        // Act
        final result = UserArticleModel.fromJson(jsonWithStringDates);

        // Assert
        expect(result.createdAt, testCreatedAt);
        expect(result.updatedAt, testUpdatedAt);
        expect(result.publishedAt, testPublishedAt);
      });

      test('should handle null optional fields', () {
        // Arrange
        final minimalJson = {
          'id': 'article123',
          'title': 'Test Article',
          'content': 'Content',
          'authorId': 'user123',
        };

        // Act
        final result = UserArticleModel.fromJson(minimalJson);

        // Assert
        expect(result.id, 'article123');
        expect(result.title, 'Test Article');
        expect(result.authorName, isNull);
        expect(result.thumbnailUrl, isNull);
        expect(result.categories, isNull);
        expect(result.isDraft, true); // default
        expect(result.publishedAt, isNull);
      });

      test('should handle empty categories list', () {
        // Arrange
        final jsonEmptyCategories = {
          ...testJson,
          'categories': <String>[],
        };

        // Act
        final result = UserArticleModel.fromJson(jsonEmptyCategories);

        // Assert
        expect(result.categories, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert UserArticleModel to JSON', () {
        // Act
        final result = testArticleModel.toJson();

        // Assert
        expect(result['id'], 'article123');
        expect(result['title'], 'Test Article');
        expect(result['description'], 'Test description');
        expect(result['content'], 'This is test content.');
        expect(result['authorId'], 'user123');
        expect(result['authorName'], 'Test Author');
        expect(result['thumbnailUrl'], 'https://example.com/cover.jpg');
        expect(result['categories'], ['tech', 'news']);
        expect(result['isDraft'], false);
        expect(result['createdAt'], isA<Timestamp>());
        expect(result['updatedAt'], isA<Timestamp>());
        expect(result['publishedAt'], isA<Timestamp>());
      });

      test('should handle null dates in toJson', () {
        // Arrange
        const modelWithNullDates = UserArticleModel(
          id: 'article123',
          title: 'Test Article',
          content: 'Content',
          authorId: 'user123',
        );

        // Act
        final result = modelWithNullDates.toJson();

        // Assert
        expect(result['createdAt'], isNull);
        expect(result['updatedAt'], isNull);
        expect(result['publishedAt'], isNull);
      });
    });

    group('toCreateJson', () {
      test('should not include id field for creation', () {
        // Act
        final result = testArticleModel.toCreateJson();

        // Assert
        expect(result.containsKey('id'), false);
        expect(result['title'], 'Test Article');
        expect(result['content'], 'This is test content.');
        expect(result['authorId'], 'user123');
      });
    });

    group('fromEntity', () {
      test('should create UserArticleModel from UserArticleEntity', () {
        // Arrange
        final entity = UserArticleEntity(
          id: 'article456',
          title: 'Entity Article',
          description: 'Entity description',
          content: 'Entity content',
          authorId: 'author789',
          authorName: 'Entity Author',
          thumbnailUrl: 'https://example.com/entity-cover.jpg',
          categories: ['science'],
          isDraft: true,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final result = UserArticleModel.fromEntity(entity);

        // Assert
        expect(result.id, 'article456');
        expect(result.title, 'Entity Article');
        expect(result.description, 'Entity description');
        expect(result.content, 'Entity content');
        expect(result.authorId, 'author789');
        expect(result.authorName, 'Entity Author');
        expect(result.thumbnailUrl, 'https://example.com/entity-cover.jpg');
        expect(result.categories, ['science']);
        expect(result.isDraft, true);
        expect(result.createdAt, testCreatedAt);
        expect(result.updatedAt, testUpdatedAt);
      });

      test('should handle entity with null optional fields', () {
        // Arrange
        const entity = UserArticleEntity(
          id: 'article456',
          title: 'Minimal Entity',
          content: 'Content',
          authorId: 'author789',
        );

        // Act
        final result = UserArticleModel.fromEntity(entity);

        // Assert
        expect(result.id, 'article456');
        expect(result.title, 'Minimal Entity');
        expect(result.authorName, isNull);
        expect(result.thumbnailUrl, isNull);
        expect(result.categories, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Act
        final result = testArticleModel.copyWith(
          title: 'Updated Title',
          content: 'Updated content',
          isDraft: true,
        );

        // Assert
        expect(result.id, 'article123');
        expect(result.title, 'Updated Title');
        expect(result.content, 'Updated content');
        expect(result.authorId, 'user123');
        expect(result.isDraft, true);
        expect(result.categories, ['tech', 'news']);
      });

      test('should create exact copy when no arguments provided', () {
        // Act
        final result = testArticleModel.copyWith();

        // Assert
        expect(result.id, testArticleModel.id);
        expect(result.title, testArticleModel.title);
        expect(result.content, testArticleModel.content);
        expect(result.authorId, testArticleModel.authorId);
        expect(result.categories, testArticleModel.categories);
        expect(result.isDraft, testArticleModel.isDraft);
      });

      test('should update categories correctly', () {
        // Act
        final result = testArticleModel.copyWith(
          categories: ['sports', 'entertainment'],
        );

        // Assert
        expect(result.categories, ['sports', 'entertainment']);
        expect(testArticleModel.categories,
            ['tech', 'news']); // Original unchanged
      });
    });

    group('equality', () {
      test('two UserArticleModels with same values should be equal', () {
        // Arrange
        final model1 = UserArticleModel(
          id: 'article123',
          title: 'Test Article',
          content: 'Content',
          authorId: 'user123',
          createdAt: testCreatedAt,
        );
        final model2 = UserArticleModel(
          id: 'article123',
          title: 'Test Article',
          content: 'Content',
          authorId: 'user123',
          createdAt: testCreatedAt,
        );

        // Assert
        expect(model1, equals(model2));
      });

      test('two UserArticleModels with different values should not be equal',
          () {
        // Arrange
        const model1 = UserArticleModel(
          id: 'article123',
          title: 'Test Article',
          content: 'Content',
          authorId: 'user123',
        );
        const model2 = UserArticleModel(
          id: 'article456',
          title: 'Test Article',
          content: 'Content',
          authorId: 'user123',
        );

        // Assert
        expect(model1, isNot(equals(model2)));
      });
    });

    group('inheritance', () {
      test('UserArticleModel should extend UserArticleEntity', () {
        // Assert
        expect(testArticleModel, isA<UserArticleModel>());
        expect(testArticleModel, isA<UserArticleEntity>());
      });
    });
  });
}
