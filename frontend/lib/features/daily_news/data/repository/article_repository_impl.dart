import 'dart:io';

import 'package:news_app_clean_architecture/core/extensions/data_exception_extensions.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_service.dart.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:sqflite/sqflite.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsService _newsService;
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._newsService, this._appDatabase);

  @override
  Future<DataState<PageEntity<ArticleEntity>>> getNewsArticles({
    required int page,
    int size = 10,
    int? total,
  }) async {
    try {
      final result = await _newsService.getNewsArticles(
        page: page,
        size: size,
        total: total,
      );

      return DataSuccess(
        PageEntity<ArticleEntity>(
          content: result.content
              .map((articleModel) => articleModel.toEntity())
              .toList(),
          page: result.page,
          totalPages: result.totalPages,
          total: result.total,
        ),
      );
    } on Exception catch (e) {
      return DataFailed(e.exception);
    }
  }

  @override
  Future<DataState<List<ArticleModel>>> getSavedArticles() async {
    try {
      return DataSuccess(await _appDatabase.articleDAO.getArticles());
    } on DatabaseException catch (e) {
      return DataFailed(e.exception);
    }
  }

  @override
  Future<DataState<void>> removeArticle(ArticleEntity article) async {
    try {
      await _appDatabase.articleDAO
          .deleteArticle(ArticleModel.fromEntity(article));

      return const DataSuccess(null);
    } on Exception catch (e) {
      return DataFailed(e.exception);
    }
  }

  @override
  Future<DataState<void>> saveArticle(ArticleEntity article) async {
    try {
      await _appDatabase.articleDAO
          .insertArticle(ArticleModel.fromEntity(article));

      return const DataSuccess(null);
    } on Exception catch (e) {
      return DataFailed(e.exception);
    }
  }

  @override
  Future<DataState<void>> createArticle({
    required ArticleEntity article,
    required File image,
  }) async {
    try {
      final imageUrl = await _newsService.uploadImage(image);
      await _newsService.saveArticle(
        ArticleModel.fromEntity(
          article.copyWith(
            url: imageUrl,
          ),
        ),
      );

      return const DataSuccess(null);
    } on Exception catch (e) {
      return DataFailed(e.exception);
    }
  }

  @override
  Future<DataState<ArticleEntity?>> getSavedArticle(String id) async {
    try {
      final article = await _appDatabase.articleDAO.getArticleById(id);

      return DataSuccess(article?.toEntity());
    } on DatabaseException catch (e) {
      return DataFailed(e.exception);
    }
  }
}
