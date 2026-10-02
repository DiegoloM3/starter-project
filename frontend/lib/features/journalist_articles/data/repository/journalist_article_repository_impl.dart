import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/article_thumbnail_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/journalist_article_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/journalist_article_repository.dart';

class JournalistArticleRepositoryImpl implements JournalistArticleRepository {
  final JournalistArticleRemoteDataSource _articleDataSource;
  final ArticleThumbnailRemoteDataSource _thumbnailDataSource;

  JournalistArticleRepositoryImpl(this._articleDataSource, this._thumbnailDataSource);

  @override
  Future<DataState<List<JournalistArticleEntity>>> getPublishedArticles() async {
    try {
      final articles = await _articleDataSource.getPublishedArticles();
      return DataSuccess(articles.map((article) => article.toEntity()).toList());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  /// The thumbnail is uploaded first, so the article is only created once its image exists.
  @override
  Future<DataState<JournalistArticleEntity>> publishArticle(ArticleDraftEntity draft) async {
    try {
      final articleId = _articleDataSource.generateArticleId();
      final thumbnail = ArticleThumbnailModel.fromEntity(draft.thumbnail!);
      final thumbnailURL = await _thumbnailDataSource.uploadThumbnail(articleId, thumbnail);
      final rawData = JournalistArticleModel.buildRawDataOfNewArticle(draft, thumbnailURL);
      final article = await _articleDataSource.createArticle(articleId, rawData);
      return DataSuccess(article.toEntity());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }
}
