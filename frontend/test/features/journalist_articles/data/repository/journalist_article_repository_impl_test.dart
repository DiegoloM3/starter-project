import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/article_thumbnail_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/journalist_article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/journalist_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

class MockJournalistArticleRemoteDataSource extends Mock implements JournalistArticleRemoteDataSource {}

class MockArticleThumbnailRemoteDataSource extends Mock implements ArticleThumbnailRemoteDataSource {}

void main() {
  late MockJournalistArticleRemoteDataSource articleDataSource;
  late MockArticleThumbnailRemoteDataSource thumbnailDataSource;
  late JournalistArticleRepositoryImpl repository;

  const articleId = 'article1';
  const thumbnailURL = 'https://example.com/media%2Farticles%2Farticle1.jpg';
  final draft = ArticleDraftEntity(
    title: 'A title',
    description: 'A description',
    content: 'Some content',
    thumbnail: ArticleThumbnailEntity(bytes: Uint8List(8), fileExtension: 'JPG'),
  );
  final storedArticle = JournalistArticleModel(
    id: articleId,
    title: draft.title,
    description: draft.description,
    content: draft.content,
    author: 'Jane Doe',
    authorId: 'janeDoeUid',
    thumbnailURL: thumbnailURL,
    publishedAt: DateTime.utc(2026, 9, 30),
  );

  setUpAll(() => registerFallbackValue(ArticleThumbnailModel(bytes: Uint8List(0), fileExtension: '')));

  setUp(() {
    articleDataSource = MockJournalistArticleRemoteDataSource();
    thumbnailDataSource = MockArticleThumbnailRemoteDataSource();
    repository = JournalistArticleRepositoryImpl(articleDataSource, thumbnailDataSource);
  });

  group('getPublishedArticles', () {
    test('returns the stored articles as entities', () async {
      when(() => articleDataSource.getPublishedArticles()).thenAnswer((_) async => [storedArticle]);

      final dataState = await repository.getPublishedArticles();

      expect(dataState, isA<DataSuccess>());
      expect(dataState.data, [storedArticle.toEntity()]);
      expect(dataState.data!.single, isNot(isA<JournalistArticleModel>()));
    });

    test('returns the exception thrown by the data source as a failure', () async {
      final error = Exception('No connection');
      when(() => articleDataSource.getPublishedArticles()).thenThrow(error);

      final dataState = await repository.getPublishedArticles();

      expect(dataState, isA<DataFailed>());
      expect(dataState.error, error);
    });
  });

  group('publishArticle', () {
    setUp(() {
      when(() => articleDataSource.generateArticleId()).thenReturn(articleId);
      when(() => thumbnailDataSource.uploadThumbnail(articleId, any())).thenAnswer((_) async => thumbnailURL);
      when(() => articleDataSource.createArticle(articleId, any())).thenAnswer((_) async => storedArticle);
    });

    test('uploads the thumbnail named after the article and then creates the article', () async {
      final dataState = await repository.publishArticle(draft);

      expect(dataState, isA<DataSuccess>());
      expect(dataState.data, storedArticle.toEntity());
      final uploadedThumbnail =
          verify(() => thumbnailDataSource.uploadThumbnail(articleId, captureAny())).captured.single
              as ArticleThumbnailModel;
      expect(uploadedThumbnail.fileExtension, 'jpg');
      verify(() => articleDataSource.createArticle(
            articleId,
            JournalistArticleModel.buildRawDataOfNewArticle(draft, thumbnailURL),
          )).called(1);
    });

    test('does not create the article when the thumbnail cannot be uploaded', () async {
      final error = Exception('Upload failed');
      when(() => thumbnailDataSource.uploadThumbnail(articleId, any())).thenThrow(error);

      final dataState = await repository.publishArticle(draft);

      expect(dataState, isA<DataFailed>());
      expect(dataState.error, error);
      verifyNever(() => articleDataSource.createArticle(any(), any()));
    });

    test('returns the exception thrown when creating the article as a failure', () async {
      final error = Exception('Permission denied');
      when(() => articleDataSource.createArticle(articleId, any())).thenThrow(error);

      final dataState = await repository.publishArticle(draft);

      expect(dataState, isA<DataFailed<JournalistArticleEntity>>());
      expect(dataState.error, error);
    });
  });
}
