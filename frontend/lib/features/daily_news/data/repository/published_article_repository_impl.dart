import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_thumbnail_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/articles_firestore_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/published_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/published_article_repository.dart';

class PublishedArticleRepositoryImpl implements PublishedArticleRepository {
  final ArticlesFirestoreService _articlesFirestoreService;
  final ArticleThumbnailStorageService _articleThumbnailStorageService;

  PublishedArticleRepositoryImpl(this._articlesFirestoreService, this._articleThumbnailStorageService);

  /// Follows the publishing flow of backend/docs/DB_SCHEMA.md: the thumbnail
  /// is uploaded before the article is created, so an article never
  /// references a missing image.
  @override
  Future<DataState<void>> publishArticle(ArticleDraftEntity draft) async {
    try {
      final articleId = _articlesFirestoreService.createArticleId();
      final thumbnailPath =
          await _articleThumbnailStorageService.uploadThumbnail(articleId, draft.thumbnailPath!);
      final rawArticle = PublishedArticleModel.toRawData(draft, thumbnailPath: thumbnailPath);
      await _articlesFirestoreService.createArticle(articleId, rawArticle);
      return const DataSuccess(null);
    } on Exception catch (exception) {
      return DataFailed(exception);
    }
  }

  @override
  Future<DataState<List<PublishedArticleEntity>>> getPublishedArticles() async {
    try {
      final rawArticles = await _articlesFirestoreService.getLatestArticles();
      final articles = await Future.wait(rawArticles.map(_buildModel));
      return DataSuccess(articles.map((article) => article.toEntity()).toList());
    } on Exception catch (exception) {
      return DataFailed(exception);
    }
  }

  Future<PublishedArticleModel> _buildModel(Map<String, dynamic> rawArticle) async {
    final thumbnailPath = rawArticle[PublishedArticleModel.thumbnailPathField] as String;
    final thumbnailUrl = await _articleThumbnailStorageService.getDownloadUrl(thumbnailPath);
    return PublishedArticleModel.fromRawData(rawArticle, thumbnailUrl: thumbnailUrl);
  }
}
