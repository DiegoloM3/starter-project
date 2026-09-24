import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article_publish_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_management/article_management_state.dart';

class ArticleManagementCubit extends Cubit<ArticleManagementState> {
  final GetUserArticlesUseCase _getUserArticlesUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  final UpdateArticlePublishStatusUseCase _updatePublishStatusUseCase;

  ArticleManagementCubit({
    required GetUserArticlesUseCase getUserArticlesUseCase,
    required DeleteArticleUseCase deleteArticleUseCase,
    required UpdateArticlePublishStatusUseCase updatePublishStatusUseCase,
  })  : _getUserArticlesUseCase = getUserArticlesUseCase,
        _deleteArticleUseCase = deleteArticleUseCase,
        _updatePublishStatusUseCase = updatePublishStatusUseCase,
        super(const ArticleManagementInitial());

  Future<void> loadUserArticles({
    required String userId,
    int limit = 10,
    String? cursor,
  }) async {
    emit(const ArticleManagementLoading());

    try {
      final params = GetUserArticlesParams(
        userId: userId,
        limit: limit,
        cursor: cursor,
      );

      final result = await _getUserArticlesUseCase(params: params);

      if (result is DataSuccess) {
        emit(ArticleManagementSuccess(articles: (result as DataSuccess).data));
      } else if (result is DataFailed) {
        emit(ArticleManagementFailure(
          error: (result as DataFailed).error?.message ?? 'Failed to load articles',
        ));
      }
    } catch (e) {
      emit(ArticleManagementFailure(error: e.toString()));
    }
  }

  Future<void> deleteArticle(String articleId) async {
    try {
      final params = DeleteArticleParams(articleId: articleId);
      final result = await _deleteArticleUseCase(params: params);

      if (result is DataSuccess) {
        emit(ArticleDeleted(articleId: articleId));
      } else if (result is DataFailed) {
        emit(ArticleManagementFailure(
          error: (result as DataFailed).error?.message ?? 'Failed to delete article',
        ));
      }
    } catch (e) {
      emit(ArticleManagementFailure(error: e.toString()));
    }
  }

  Future<void> updatePublishStatus({
    required String articleId,
    required bool isPublished,
  }) async {
    try {
      final params = UpdatePublishStatusParams(
        articleId: articleId,
        isPublished: isPublished,
      );

      final result = await _updatePublishStatusUseCase(params: params);

      if (result is DataSuccess) {
        emit(ArticlePublishStatusUpdated(
          articleId: articleId,
          isPublished: isPublished,
        ));
      } else if (result is DataFailed) {
        emit(ArticleManagementFailure(
          error: (result as DataFailed).error?.message ??
              'Failed to update publish status',
        ));
      }
    } catch (e) {
      emit(ArticleManagementFailure(error: e.toString()));
    }
  }
}
