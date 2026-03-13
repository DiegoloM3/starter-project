import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/models/user_article_model.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/repository/user_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late UserArticleRepositoryImpl repository;
  late MockArticleRemoteDataSource mockArticleDataSource;
  late MockCloudinaryService mockCloudinaryService;

  setUp(() {
    mockArticleDataSource = MockArticleRemoteDataSource();
    mockCloudinaryService = MockCloudinaryService();
    repository = UserArticleRepositoryImpl(
      articleRemoteDataSource: mockArticleDataSource,
      cloudinaryService: mockCloudinaryService,
    );
  });

  final testCreatedAt = DateTime(2024, 1, 1);
  final testUpdatedAt = DateTime(2024, 1, 2);

  final testArticleModel = UserArticleModel(
    id: 'article123',
    title: 'Test Article',
    description: 'Test description',
    content: 'Test content',
    authorId: 'user123',
    authorName: 'Test Author',
    thumbnailUrl: 'https://example.com/cover.jpg',
    categories: ['tech'],
    isDraft: false,
    createdAt: testCreatedAt,
    updatedAt: testUpdatedAt,
  );

  final testArticleEntity = UserArticleEntity(
    id: 'article123',
    title: 'Test Article',
    description: 'Test description',
    content: 'Test content',
    authorId: 'user123',
    authorName: 'Test Author',
    thumbnailUrl: 'https://example.com/cover.jpg',
    categories: ['tech'],
    isDraft: false,
    createdAt: testCreatedAt,
    updatedAt: testUpdatedAt,
  );

  group('createArticle', () {
    test('should return DataSuccess with article when data source succeeds',
        () async {
      // Arrange
      when(mockArticleDataSource.createArticle(any))
          .thenAnswer((_) async => testArticleModel);

      // Act
      final result = await repository.createArticle(testArticleEntity);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, testArticleModel);
      verify(mockArticleDataSource.createArticle(any)).called(1);
    });

    test('should return DataFailed when data source throws', () async {
      // Arrange
      when(mockArticleDataSource.createArticle(any))
          .thenThrow(Exception('Creation failed'));

      // Act
      final result = await repository.createArticle(testArticleEntity);

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception.toString(),
          contains('Failed to create article'));
    });
  });

  group('updateArticle', () {
    test(
        'should return DataSuccess with updated article when data source succeeds',
        () async {
      // Arrange
      final updatedModel = testArticleModel.copyWith(title: 'Updated Title');
      when(mockArticleDataSource.updateArticle(any))
          .thenAnswer((_) async => updatedModel);

      // Act
      final updatedEntity = testArticleEntity.copyWith(title: 'Updated Title');
      final result = await repository.updateArticle(updatedEntity);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data.title, 'Updated Title');
      verify(mockArticleDataSource.updateArticle(any)).called(1);
    });

    test('should return DataFailed when data source throws', () async {
      // Arrange
      when(mockArticleDataSource.updateArticle(any))
          .thenThrow(Exception('Update failed'));

      // Act
      final result = await repository.updateArticle(testArticleEntity);

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception.toString(),
          contains('Failed to update article'));
    });
  });

  group('deleteArticle', () {
    test('should return DataSuccess when data source succeeds', () async {
      // Arrange
      when(mockArticleDataSource.deleteArticle(any)).thenAnswer((_) async {});

      // Act
      final result = await repository.deleteArticle('article123');

      // Assert
      expect(result, isA<DataSuccess>());
      verify(mockArticleDataSource.deleteArticle('article123')).called(1);
    });

    test('should return DataFailed when data source throws', () async {
      // Arrange
      when(mockArticleDataSource.deleteArticle(any))
          .thenThrow(Exception('Delete failed'));

      // Act
      final result = await repository.deleteArticle('article123');

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception.toString(),
          contains('Failed to delete article'));
    });
  });

  group('getArticleById', () {
    test('should return DataSuccess with article when found', () async {
      // Arrange
      when(mockArticleDataSource.getArticleById(any))
          .thenAnswer((_) async => testArticleModel);

      // Act
      final result = await repository.getArticleById('article123');

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, testArticleModel);
      verify(mockArticleDataSource.getArticleById('article123')).called(1);
    });

    test('should return DataFailed when article not found', () async {
      // Arrange
      when(mockArticleDataSource.getArticleById(any))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getArticleById('nonexistent');

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception.toString(),
          contains('Article not found'));
    });

    test('should return DataFailed when data source throws', () async {
      // Arrange
      when(mockArticleDataSource.getArticleById(any))
          .thenThrow(Exception('Fetch failed'));

      // Act
      final result = await repository.getArticleById('article123');

      // Assert
      expect(result, isA<DataFailed>());
    });
  });

  group('getPublishedArticles', () {
    test('should return DataSuccess with list of articles', () async {
      // Arrange
      final List<UserArticleModel> articles = [
        testArticleModel,
        testArticleModel.copyWith(id: 'article456')
      ];
      when(mockArticleDataSource.getPublishedArticles())
          .thenAnswer((_) async => articles);

      // Act
      final result = await repository.getPublishedArticles();

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data.length, 2);
      verify(mockArticleDataSource.getPublishedArticles()).called(1);
    });

    test('should return DataSuccess with empty list when no articles',
        () async {
      // Arrange
      when(mockArticleDataSource.getPublishedArticles())
          .thenAnswer((_) async => <UserArticleModel>[]);

      // Act
      final result = await repository.getPublishedArticles();

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, isEmpty);
    });

    test('should return DataFailed when data source throws', () async {
      // Arrange
      when(mockArticleDataSource.getPublishedArticles())
          .thenThrow(Exception('Fetch failed'));

      // Act
      final result = await repository.getPublishedArticles();

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception.toString(),
          contains('Failed to get published articles'));
    });
  });

  group('getUserArticles', () {
    test('should return DataSuccess with user articles', () async {
      // Arrange
      final List<UserArticleModel> articles = [testArticleModel];
      when(mockArticleDataSource.getUserArticles(any))
          .thenAnswer((_) async => articles);

      // Act
      final result = await repository.getUserArticles('user123');

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data.length, 1);
      verify(mockArticleDataSource.getUserArticles('user123')).called(1);
    });

    test('should return DataFailed when data source throws', () async {
      // Arrange
      when(mockArticleDataSource.getUserArticles(any))
          .thenThrow(Exception('Fetch failed'));

      // Act
      final result = await repository.getUserArticles('user123');

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception.toString(),
          contains('Failed to get user articles'));
    });
  });

  group('getArticlesByCategory', () {
    test('should return DataSuccess with filtered articles', () async {
      // Arrange
      final List<UserArticleModel> articles = [testArticleModel];
      when(mockArticleDataSource.getArticlesByCategory(any))
          .thenAnswer((_) async => articles);

      // Act
      final result = await repository.getArticlesByCategory('tech');

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data.length, 1);
      verify(mockArticleDataSource.getArticlesByCategory('tech')).called(1);
    });

    test('should return DataFailed when data source throws', () async {
      // Arrange
      when(mockArticleDataSource.getArticlesByCategory(any))
          .thenThrow(Exception('Fetch failed'));

      // Act
      final result = await repository.getArticlesByCategory('tech');

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception.toString(),
          contains('Failed to get articles by category'));
    });
  });

  group('publishArticle', () {
    test('should return DataSuccess with published article', () async {
      // Arrange
      final publishedModel = testArticleModel.copyWith(
        isDraft: false,
        publishedAt: DateTime.now(),
      );
      when(mockArticleDataSource.publishArticle(any))
          .thenAnswer((_) async => publishedModel);

      // Act
      final result = await repository.publishArticle('article123');

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data.isDraft, false);
      verify(mockArticleDataSource.publishArticle('article123')).called(1);
    });

    test('should return DataFailed when data source throws', () async {
      // Arrange
      when(mockArticleDataSource.publishArticle(any))
          .thenThrow(Exception('Publish failed'));

      // Act
      final result = await repository.publishArticle('article123');

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception.toString(),
          contains('Failed to publish article'));
    });
  });

  group('unpublishArticle', () {
    test('should return DataSuccess with unpublished article', () async {
      // Arrange
      final unpublishedModel = testArticleModel.copyWith(isDraft: true);
      when(mockArticleDataSource.unpublishArticle(any))
          .thenAnswer((_) async => unpublishedModel);

      // Act
      final result = await repository.unpublishArticle('article123');

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data.isDraft, true);
      verify(mockArticleDataSource.unpublishArticle('article123')).called(1);
    });

    test('should return DataFailed when data source throws', () async {
      // Arrange
      when(mockArticleDataSource.unpublishArticle(any))
          .thenThrow(Exception('Unpublish failed'));

      // Act
      final result = await repository.unpublishArticle('article123');

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception.toString(),
          contains('Failed to unpublish article'));
    });
  });

  group('uploadImage', () {
    test('should return DataSuccess with image URL when upload succeeds',
        () async {
      // Arrange
      final fakeFile = FakeFile('/path/to/image.jpg');
      when(mockCloudinaryService.uploadImage(any, folder: anyNamed('folder')))
          .thenAnswer((_) async => 'https://cloudinary.com/uploaded-image.jpg');

      // Act
      final result = await repository.uploadImage(fakeFile);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data,
          'https://cloudinary.com/uploaded-image.jpg');
      verify(mockCloudinaryService.uploadImage(fakeFile, folder: 'articles'))
          .called(1);
    });

    test('should return DataFailed when upload fails', () async {
      // Arrange
      final fakeFile = FakeFile('/path/to/image.jpg');
      when(mockCloudinaryService.uploadImage(any, folder: anyNamed('folder')))
          .thenThrow(Exception('Upload failed'));

      // Act
      final result = await repository.uploadImage(fakeFile);

      // Assert
      expect(result, isA<DataFailed>());
      expect((result as DataFailed).exception.toString(),
          contains('Failed to upload image'));
    });
  });
}

/// Fake File implementation for testing
class FakeFile implements File {
  final String _path;

  FakeFile(this._path);

  @override
  String get path => _path;

  // Implement required abstract methods with minimal functionality
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
