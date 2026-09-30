import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/article_thumbnail_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/published_articles_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/published_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/invalid_article_draft_exception.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/get_published_articles_params.dart';

class MockArticlesDataSource extends Mock implements PublishedArticlesFirestoreDataSource {}

class MockThumbnailsDataSource extends Mock implements ArticleThumbnailStorageDataSource {}

const articleId = 'Xk3P9aQzT1mB7cL2vR8w';
const thumbnailUrl = 'https://firebasestorage.googleapis.com/v0/b/bucket/o/media%2Farticles%2FXk3P9aQzT1mB7cL2vR8w.jpg';
const thumbnail = ArticleThumbnailEntity(localPath: '/gallery/photo.jpg', sizeInBytes: 1024);
const draft = ArticleDraftEntity(
  title: 'Breaking News!',
  content: 'This is **breaking** news.',
  author: 'Daily News Staff',
  thumbnail: thumbnail,
);

final storedArticle = PublishedArticleModel(
  id: articleId,
  title: 'Breaking News!',
  content: 'This is **breaking** news.',
  description: 'This is breaking news.',
  author: 'Daily News Staff',
  thumbnailUrl: thumbnailUrl,
  publishedAt: DateTime.utc(2026, 9, 28),
);

void main() {
  late MockArticlesDataSource articles;
  late MockThumbnailsDataSource thumbnails;
  late PublishedArticleRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(thumbnail));

  setUp(() {
    articles = MockArticlesDataSource();
    thumbnails = MockThumbnailsDataSource();
    repository = PublishedArticleRepositoryImpl(articles, thumbnails);
    when(() => articles.newArticleId()).thenReturn(articleId);
    when(() => thumbnails.uploadThumbnail(any(), any())).thenAnswer((_) async {});
    when(() => thumbnails.getThumbnailUrl(any(), any())).thenAnswer((_) async => thumbnailUrl);
    when(() => thumbnails.deleteThumbnail(any(), any())).thenAnswer((_) async {});
    when(() => articles.createArticle(any(), any())).thenAnswer((_) async {});
  });

  group('publishArticle', () {
    test('uploads the thumbnail first, then stores the article pointing to it', () async {
      final result = await repository.publishArticle(draft);

      expect(result, isA<DataSuccess<void>>());
      verifyInOrder([
        () => thumbnails.uploadThumbnail(articleId, thumbnail),
        () => thumbnails.getThumbnailUrl(articleId, thumbnail),
        () => articles.createArticle(articleId, PublishedArticleModel.newDocumentFields(draft, thumbnailUrl)),
      ]);
      verifyNever(() => thumbnails.deleteThumbnail(any(), any()));
    });

    test('does not store the article when the thumbnail upload fails', () async {
      final error = Exception('upload failed');
      when(() => thumbnails.uploadThumbnail(any(), any())).thenThrow(error);

      final result = await repository.publishArticle(draft);

      expect(result.error, same(error));
      verifyNever(() => articles.createArticle(any(), any()));
    });

    test('removes the uploaded thumbnail when the article cannot be stored', () async {
      final error = Exception('permission-denied');
      when(() => articles.createArticle(any(), any())).thenThrow(error);

      final result = await repository.publishArticle(draft);

      expect(result.error, same(error));
      verify(() => thumbnails.deleteThumbnail(articleId, thumbnail)).called(1);
    });

    test('reports the original error even if removing the thumbnail also fails', () async {
      final error = Exception('offline');
      when(() => articles.createArticle(any(), any())).thenThrow(error);
      when(() => thumbnails.deleteThumbnail(any(), any())).thenThrow(Exception('still offline'));

      final result = await repository.publishArticle(draft);

      expect(result.error, same(error));
    });

    test('rejects a draft without thumbnail without touching the backend', () async {
      final result = await repository.publishArticle(const ArticleDraftEntity(title: 'No image'));

      expect((result.error! as InvalidArticleDraftException).errors, {ArticleDraftError.thumbnailMissing});
      verifyNever(() => thumbnails.uploadThumbnail(any(), any()));
    });
  });

  group('getPublishedArticles', () {
    test('asks for the requested page and returns entities, not models', () async {
      when(() => articles.getArticles(limit: 20, startAfterArticleId: 'previous'))
          .thenAnswer((_) async => [storedArticle]);

      final result = await repository.getPublishedArticles(
        GetPublishedArticlesParams(startAfter: storedArticle.toEntity().withId('previous')),
      );

      expect(result.data!.single.runtimeType, PublishedArticleEntity);
      expect(result.data!.single, storedArticle.toEntity());
    });

    test('fails when the articles cannot be loaded, including malformed documents', () async {
      const error = FormatException('Article "x" has an invalid "title"');
      when(() => articles.getArticles(limit: any(named: 'limit'), startAfterArticleId: any(named: 'startAfterArticleId')))
          .thenThrow(error);

      final result = await repository.getPublishedArticles(const GetPublishedArticlesParams());

      expect(result, isA<DataFailed<List<PublishedArticleEntity>>>());
      expect(result.error, same(error));
    });
  });
}

extension on PublishedArticleEntity {
  PublishedArticleEntity withId(String id) {
    return PublishedArticleEntity(
      id: id,
      title: title,
      content: content,
      description: description,
      author: author,
      thumbnailUrl: thumbnailUrl,
      publishedAt: publishedAt,
    );
  }
}
