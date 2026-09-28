import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/remote/user_articles_firebase_service.dart';
import 'package:news_app_clean_architecture/features/news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/news/data/repository/user_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';

import 'user_article_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserArticlesFirebaseService>()])
void main() {
  late MockUserArticlesFirebaseService mockFirebaseService;
  late UserArticleRepositoryImpl repository;

  const tArticleEntity = ArticleEntity(
    id: '1',
    authorDisplayName: 'John Doe',
    title: 'Test Title',
    urlToImage: 'https://example.com/initial.jpg',
    publishedAt: '2026-09-27T00:00:00Z',
    content: 'Test Content',
  );

  setUp(() {
    mockFirebaseService = MockUserArticlesFirebaseService();
    repository = UserArticleRepositoryImpl(mockFirebaseService);
  });

  group('createUserArticle', () {
    test(
        'should upload thumbnail and create article with uploaded url when imageFile is provided',
        () async {
      final tImageFile = File('dummy/path/image.jpg');
      const uploadedUrl = 'https://firebasestorage.googleapis.com/test.jpg';

      when(mockFirebaseService.uploadThumbnail(tImageFile))
          .thenAnswer((_) async => uploadedUrl);

      final result = await repository.createUserArticle(
        tArticleEntity,
        imageFile: tImageFile,
      );

      expect(result, isA<DataSuccess<void>>());
      verify(mockFirebaseService.uploadThumbnail(tImageFile)).called(1);

      final captured = verify(mockFirebaseService.createUserArticle(captureAny))
          .captured
          .single as ArticleModel;
      expect(captured.urlToImage, uploadedUrl);
      expect(captured.title, tArticleEntity.title);
      expect(captured.content, tArticleEntity.content);
      expect(captured.authorDisplayName, tArticleEntity.authorDisplayName);
    });

    test(
        'should fallback to existing urlToImage when imageFile is null and uploadThumbnail returns null',
        () async {
      when(mockFirebaseService.uploadThumbnail(null))
          .thenAnswer((_) async => null);

      final result = await repository.createUserArticle(
        tArticleEntity,
        imageFile: null,
      );

      expect(result, isA<DataSuccess<void>>());
      verify(mockFirebaseService.uploadThumbnail(null)).called(1);

      final captured = verify(mockFirebaseService.createUserArticle(captureAny))
          .captured
          .single as ArticleModel;
      expect(captured.urlToImage, tArticleEntity.urlToImage);
    });

    test('should return DataGenericFailed when uploadThumbnail throws',
        () async {
      final tImageFile = File('dummy/path/image.jpg');
      when(mockFirebaseService.uploadThumbnail(tImageFile))
          .thenThrow(Exception('Upload failed'));

      final result = await repository.createUserArticle(
        tArticleEntity,
        imageFile: tImageFile,
      );

      expect(result, isA<DataGenericFailed<void>>());
      expect(result.errorMessage, contains('Upload failed'));
      verify(mockFirebaseService.uploadThumbnail(tImageFile)).called(1);
      verifyNever(mockFirebaseService.createUserArticle(any));
    });

    test('should return DataGenericFailed when createUserArticle throws',
        () async {
      when(mockFirebaseService.uploadThumbnail(null))
          .thenAnswer((_) async => null);
      when(mockFirebaseService.createUserArticle(any))
          .thenThrow(Exception('Firestore write failed'));

      final result = await repository.createUserArticle(
        tArticleEntity,
        imageFile: null,
      );

      expect(result, isA<DataGenericFailed<void>>());
      expect(result.errorMessage, contains('Firestore write failed'));
      verify(mockFirebaseService.uploadThumbnail(null)).called(1);
      verify(mockFirebaseService.createUserArticle(any)).called(1);
    });
  });

  group('getUserArticles', () {
    final tModels = [
      const ArticleModel(
        id: '2',
        authorDisplayName: 'John Doe',
        title: 'Newer',
        urlToImage: 'https://example.com/newer.jpg',
        publishedAt: '2026-09-27T10:00:00Z',
        content: 'Newer content',
        authorId: 'user-123',
      ),
      const ArticleModel(
        id: '1',
        authorDisplayName: 'John Doe',
        title: 'Older',
        urlToImage: 'https://example.com/older.jpg',
        publishedAt: '2026-09-26T10:00:00Z',
        content: 'Older content',
        authorId: 'user-123',
      ),
    ];

    test('should return articles from the firebase service', () async {
      when(mockFirebaseService.getUserArticles('user-123'))
          .thenAnswer((_) async => tModels);

      final result = await repository.getUserArticles('user-123');

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, hasLength(2));
      expect(result.data!.first.title, 'Newer');
      verify(mockFirebaseService.getUserArticles('user-123')).called(1);
    });

    test('should return DataGenericFailed when the service throws', () async {
      when(mockFirebaseService.getUserArticles('user-123'))
          .thenThrow(Exception('Firestore read failed'));

      final result = await repository.getUserArticles('user-123');

      expect(result, isA<DataGenericFailed<List<ArticleEntity>>>());
      expect(result.errorMessage, contains('Firestore read failed'));
    });
  });

  group('getAllUserArticles', () {
    final tModels = [
      const ArticleModel(
        id: '2',
        authorDisplayName: 'Jane Doe',
        title: 'Newer',
        urlToImage: 'https://example.com/newer.jpg',
        publishedAt: '2026-09-27T10:00:00Z',
        content: 'Newer content',
        authorId: 'user-456',
      ),
      const ArticleModel(
        id: '1',
        authorDisplayName: 'John Doe',
        title: 'Older',
        urlToImage: 'https://example.com/older.jpg',
        publishedAt: '2026-09-26T10:00:00Z',
        content: 'Older content',
        authorId: 'user-123',
      ),
    ];

    test('should return every article from the firebase service', () async {
      when(mockFirebaseService.getAllUserArticles())
          .thenAnswer((_) async => tModels);

      final result = await repository.getAllUserArticles();

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, hasLength(2));
      expect(result.data!.first.title, 'Newer');
      verify(mockFirebaseService.getAllUserArticles()).called(1);
    });

    test('should return DataGenericFailed when the service throws', () async {
      when(mockFirebaseService.getAllUserArticles())
          .thenThrow(Exception('Firestore read failed'));

      final result = await repository.getAllUserArticles();

      expect(result, isA<DataGenericFailed<List<ArticleEntity>>>());
      expect(result.errorMessage, contains('Firestore read failed'));
    });
  });

  group('updateUserArticle', () {
    test(
        'should upload thumbnail and update article with uploaded url when imageFile is provided',
        () async {
      final tImageFile = File('dummy/path/image.jpg');
      const uploadedUrl = 'https://firebasestorage.googleapis.com/updated.jpg';

      when(mockFirebaseService.uploadThumbnail(tImageFile))
          .thenAnswer((_) async => uploadedUrl);

      final result = await repository.updateUserArticle(
        tArticleEntity,
        imageFile: tImageFile,
      );

      expect(result, isA<DataSuccess<void>>());
      verify(mockFirebaseService.uploadThumbnail(tImageFile)).called(1);

      final captured = verify(mockFirebaseService.updateUserArticle(captureAny))
          .captured
          .single as ArticleModel;
      expect(captured.urlToImage, uploadedUrl);
      expect(captured.id, tArticleEntity.id);
      expect(captured.title, tArticleEntity.title);
      expect(captured.content, tArticleEntity.content);
    });

    test(
        'should keep existing urlToImage when imageFile is null and uploadThumbnail returns null',
        () async {
      when(mockFirebaseService.uploadThumbnail(null))
          .thenAnswer((_) async => null);

      final result = await repository.updateUserArticle(
        tArticleEntity,
        imageFile: null,
      );

      expect(result, isA<DataSuccess<void>>());

      final captured = verify(mockFirebaseService.updateUserArticle(captureAny))
          .captured
          .single as ArticleModel;
      expect(captured.urlToImage, tArticleEntity.urlToImage);
    });

    test('should return DataGenericFailed when uploadThumbnail throws',
        () async {
      final tImageFile = File('dummy/path/image.jpg');
      when(mockFirebaseService.uploadThumbnail(tImageFile))
          .thenThrow(Exception('Upload failed'));

      final result = await repository.updateUserArticle(
        tArticleEntity,
        imageFile: tImageFile,
      );

      expect(result, isA<DataGenericFailed<void>>());
      expect(result.errorMessage, contains('Upload failed'));
      verifyNever(mockFirebaseService.updateUserArticle(any));
    });

    test('should return DataGenericFailed when updateUserArticle throws',
        () async {
      when(mockFirebaseService.uploadThumbnail(null))
          .thenAnswer((_) async => null);
      when(mockFirebaseService.updateUserArticle(any))
          .thenThrow(Exception('Firestore update failed'));

      final result = await repository.updateUserArticle(
        tArticleEntity,
        imageFile: null,
      );

      expect(result, isA<DataGenericFailed<void>>());
      expect(result.errorMessage, contains('Firestore update failed'));
    });
  });

  group('deleteUserArticle', () {
    test('should delete the article and return DataSuccess', () async {
      final result = await repository.deleteUserArticle('1');

      expect(result, isA<DataSuccess<void>>());
      verify(mockFirebaseService.deleteUserArticle('1')).called(1);
    });

    test('should return DataGenericFailed when the service throws', () async {
      when(mockFirebaseService.deleteUserArticle('1'))
          .thenThrow(Exception('Firestore delete failed'));

      final result = await repository.deleteUserArticle('1');

      expect(result, isA<DataGenericFailed<void>>());
      expect(result.errorMessage, contains('Firestore delete failed'));
    });
  });
}
