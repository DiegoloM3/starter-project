import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_thumbnail_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/articles_firestore_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/published_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/published_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/published_article.dart';

class MockArticlesFirestoreService extends Mock implements ArticlesFirestoreService {}

class MockArticleThumbnailStorageService extends Mock implements ArticleThumbnailStorageService {}

void main() {
  late MockArticlesFirestoreService firestoreService;
  late MockArticleThumbnailStorageService storageService;
  late PublishedArticleRepositoryImpl repository;

  const draft = ArticleDraftEntity(
    title: 'Breaking News!',
    content: 'This is breaking news!',
    thumbnailPath: '/local/image.jpg',
  );

  setUp(() {
    firestoreService = MockArticlesFirestoreService();
    storageService = MockArticleThumbnailStorageService();
    repository = PublishedArticleRepositoryImpl(firestoreService, storageService);
    when(() => firestoreService.createArticleId()).thenReturn('article1');
  });

  group('publishArticle', () {
    test('uploads the thumbnail and then creates the article that references it', () async {
      when(() => storageService.uploadThumbnail('article1', '/local/image.jpg'))
          .thenAnswer((_) async => 'media/articles/article1.jpg');
      when(() => firestoreService.createArticle(any(), any())).thenAnswer((_) async {});

      final result = await repository.publishArticle(draft);

      expect(result, isA<DataSuccess<void>>());
      verifyInOrder([
        () => storageService.uploadThumbnail('article1', '/local/image.jpg'),
        () => firestoreService.createArticle('article1', {
              'title': 'Breaking News!',
              'content': 'This is breaking news!',
              'thumbnailURL': 'media/articles/article1.jpg',
            }),
      ]);
    });

    test('does not create the article when the thumbnail upload fails', () async {
      final uploadError = Exception('Upload failed');
      when(() => storageService.uploadThumbnail(any(), any())).thenThrow(uploadError);

      final result = await repository.publishArticle(draft);

      expect(result.error, uploadError);
      verifyNever(() => firestoreService.createArticle(any(), any()));
    });

    test('returns a failure when the article cannot be created', () async {
      final firestoreError = Exception('Permission denied');
      when(() => storageService.uploadThumbnail(any(), any())).thenAnswer((_) async => 'media/articles/article1.jpg');
      when(() => firestoreService.createArticle(any(), any())).thenThrow(firestoreError);

      final result = await repository.publishArticle(draft);

      expect(result.error, firestoreError);
    });
  });

  group('getPublishedArticles', () {
    test('returns the articles with the download URL of their thumbnails', () async {
      when(() => firestoreService.getLatestArticles()).thenAnswer((_) async => [
            {
              'title': 'Breaking News!',
              'content': 'This is breaking news!',
              'thumbnailURL': 'media/articles/article1.jpg',
              'publishedAt': DateTime.utc(2026, 10, 15),
            },
          ]);
      when(() => storageService.getDownloadUrl('media/articles/article1.jpg'))
          .thenAnswer((_) async => 'https://example.com/article1.jpg');

      final result = await repository.getPublishedArticles();

      expect(result.data, [
        PublishedArticleEntity(
          title: 'Breaking News!',
          content: 'This is breaking news!',
          thumbnailUrl: 'https://example.com/article1.jpg',
          publishedAt: DateTime.utc(2026, 10, 15),
        ),
      ]);
      expect(result.data!.single, isNot(isA<PublishedArticleModel>()));
    });

    test('returns a failure when the articles cannot be read', () async {
      final firestoreError = Exception('Unavailable');
      when(() => firestoreService.getLatestArticles()).thenThrow(firestoreError);

      final result = await repository.getPublishedArticles();

      expect(result.error, firestoreError);
    });
  });
}
