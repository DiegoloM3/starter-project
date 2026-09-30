import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/entities/article_draft.dart';
import '../../domain/entities/article_thumbnail.dart';
import '../../domain/entities/invalid_article_draft_exception.dart';
import '../../domain/entities/published_article.dart';
import '../../domain/params/get_published_articles_params.dart';
import '../../domain/repository/published_article_repository.dart';
import '../data_sources/remote/article_thumbnail_storage_data_source.dart';
import '../data_sources/remote/published_articles_firestore_data_source.dart';
import '../models/published_article.dart';

typedef _ThumbnailUpload = ({String articleId, ArticleThumbnailEntity thumbnail});

class PublishedArticleRepositoryImpl implements PublishedArticleRepository {
  final PublishedArticlesFirestoreDataSource _articlesDataSource;
  final ArticleThumbnailStorageDataSource _thumbnailsDataSource;

  PublishedArticleRepositoryImpl(this._articlesDataSource, this._thumbnailsDataSource);

  /// The publishing flow of backend/docs/DB_SCHEMA.md: the thumbnail is uploaded before the
  /// article is stored, so a published article never points to a missing image, and it is
  /// removed again if the article cannot be stored.
  @override
  Future<DataState<void>> publishArticle(ArticleDraftEntity draft) async {
    final thumbnail = draft.thumbnail;
    if (thumbnail == null) {
      return const DataFailed(InvalidArticleDraftException({ArticleDraftError.thumbnailMissing}));
    }
    final upload = (articleId: _articlesDataSource.newArticleId(), thumbnail: thumbnail);
    try {
      final thumbnailUrl = await _uploadThumbnail(upload);
      await _createArticleOrRemoveThumbnail(upload, PublishedArticleModel.newDocumentFields(draft, thumbnailUrl));
      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<List<PublishedArticleEntity>>> getPublishedArticles(GetPublishedArticlesParams params) async {
    try {
      final articles = await _articlesDataSource.getArticles(
        limit: params.pageSize,
        startAfterArticleId: params.startAfter?.id,
      );
      return DataSuccess(articles.map((article) => article.toEntity()).toList());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  Future<String> _uploadThumbnail(_ThumbnailUpload upload) async {
    await _thumbnailsDataSource.uploadThumbnail(upload.articleId, upload.thumbnail);
    return _thumbnailsDataSource.getThumbnailUrl(upload.articleId, upload.thumbnail);
  }

  Future<void> _createArticleOrRemoveThumbnail(_ThumbnailUpload upload, Map<String, Object> fields) async {
    try {
      await _articlesDataSource.createArticle(upload.articleId, fields);
    } on Exception {
      await _removeOrphanThumbnail(upload);
      rethrow;
    }
  }

  Future<void> _removeOrphanThumbnail(_ThumbnailUpload upload) async {
    try {
      await _thumbnailsDataSource.deleteThumbnail(upload.articleId, upload.thumbnail);
    } on Exception {
      // Best effort: the article was not published, only an unused image stays in Storage.
    }
  }
}
