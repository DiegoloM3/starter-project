import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/data/data_sources/article_remote_data_source.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/params/publish_article_params.dart';
import 'package:tortutip/features/articles/domain/params/update_article_params.dart';
import 'package:tortutip/features/articles/domain/params/upload_article_image_params.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _dataSource;
  ArticleRepositoryImpl(this._dataSource);

  @override
  Future<DataState<List<ArticleEntity>>> getFeedArticles(
      List<String> categoryIds) async {
    try {
      final models = await _dataSource.getFeedArticles(categoryIds);
      return DataSuccess(List<ArticleEntity>.from(models));
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ArticleEntity>> getArticleDetail(String articleId) async {
    try {
      final model = await _dataSource.getArticleDetail(articleId);
      return DataSuccess(model);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ArticleEntity>> publishArticle(
      PublishArticleParams params) async {
    try {
      final model = await _dataSource.publishArticle(params);
      return DataSuccess(model);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> saveArticle(String userId, String articleId) async {
    try {
      await _dataSource.saveArticle(userId, articleId);
      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getUserArticles(String userId) async {
    try {
      final models = await _dataSource.getUserArticles(userId);
      return DataSuccess(List<ArticleEntity>.from(models));
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<String>>> getSavedArticleIds(String userId) async {
    try {
      final ids = await _dataSource.getSavedArticleIds(userId);
      return DataSuccess(ids);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getFeedArticlesPaged(
      List<String> categoryIds, int page, int pageSize) async {
    try {
      final models =
          await _dataSource.getFeedArticlesPaged(categoryIds, page, pageSize);
      return DataSuccess(List<ArticleEntity>.from(models));
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> unsaveArticle(String userId, String articleId) async {
    try {
      await _dataSource.unsaveArticle(userId, articleId);
      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getRelatedArticles(
      String categoryId, String excludeArticleId) async {
    try {
      final models =
          await _dataSource.getRelatedArticles(categoryId, excludeArticleId);
      return DataSuccess(List<ArticleEntity>.from(models));
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<String>> uploadArticleImage(
      UploadArticleImageParams params) async {
    try {
      final url = await _dataSource.uploadArticleImage(params);
      return DataSuccess(url);
    } on Exception catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(Exception(e.toString()));
    }
  }

  @override
  Future<DataState<ArticleEntity>> updateArticle(
      UpdateArticleParams params) async {
    try {
      final model = await _dataSource.updateArticle(params);
      return DataSuccess(model);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }
}
