import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_article_detail_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_related_articles_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_saved_article_ids_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/save_article_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/unsave_article_use_case.dart';
import 'package:tortutip/features/tortu_feed/domain/repository/tortu_feed_repository.dart';
import 'package:tortutip/features/tortu_feed/domain/use_cases/feed_tortu_use_case.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/use_cases/get_user_by_id_use_case.dart';
import 'package:tortutip/shared/user/domain/use_cases/record_feed_swipe_use_case.dart';

import 'article_detail_state.dart';

class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  final GetArticleDetailUseCase _getArticleDetail;
  final GetRelatedArticlesUseCase _getRelatedArticles;
  final SaveArticleUseCase _saveArticle;
  final UnsaveArticleUseCase _unsaveArticle;
  final GetUserByIdUseCase _getUserById;
  final GetSavedArticleIdsUseCase _getSavedArticleIds;
  final FeedTortuUseCase _feedTortu;
  final RecordFeedSwipeUseCase _recordFeedSwipe;

  ArticleDetailCubit(
    this._getArticleDetail,
    this._getRelatedArticles,
    this._saveArticle,
    this._unsaveArticle,
    this._getUserById,
    this._getSavedArticleIds,
    this._feedTortu,
    this._recordFeedSwipe,
  ) : super(const ArticleDetailInitial());

  Future<void> loadArticle(
    String articleId,
    String currentUserId, {
    bool isDoneToday = false,
  }) async {
    emit(const ArticleDetailLoading());

    final articleResult = await _getArticleDetail(articleId);
    if (!articleResult.isSuccess) {
      emit(ArticleDetailError(_mapErrorToMessage(articleResult.error!)));
      return;
    }
    final article = articleResult.data!;

    // Parallel calls that don't depend on each other
    final results = await Future.wait([
      _getUserById(GetUserByIdParams(userId: article.authorId)),
      _getSavedArticleIds(GetSavedArticleIdsParams(userId: currentUserId)),
      _getRelatedArticles(GetRelatedArticlesParams(
        categoryId: article.categoryId,
        excludeArticleId: articleId,
      )),
    ]);

    final authorResult = results[0];
    final savedIdsResult = results[1];
    final relatedResult = results[2];

    if (!authorResult.isSuccess) {
      emit(ArticleDetailError(_mapErrorToMessage(authorResult.error!)));
      return;
    }

    final author = authorResult.data! as UserEntity;
    final savedIds = savedIdsResult.isSuccess
        ? (savedIdsResult.data as List<String>)
        : <String>[];
    final isSaved = savedIds.contains(articleId);
    final relatedArticles = relatedResult.isSuccess
        ? List<ArticleEntity>.from(relatedResult.data as List)
        : <ArticleEntity>[];

    emit(ArticleDetailLoaded(
      article: article,
      author: author,
      isSaved: isSaved,
      relatedArticles: relatedArticles,
      isDoneToday: isDoneToday,
    ));
  }

  // Returns true if save/unsave succeeded, false if it failed (for SnackBar from Screen)
  Future<bool> toggleSave(String userId) async {
    if (state is! ArticleDetailLoaded) return false;
    final loaded = state as ArticleDetailLoaded;
    final previouslySaved = loaded.isSaved;

    // Optimistic update
    emit(ArticleDetailLoaded(
      article: loaded.article,
      author: loaded.author,
      isSaved: !previouslySaved,
      relatedArticles: loaded.relatedArticles,
      isDoneToday: loaded.isDoneToday,
    ));

    final result = previouslySaved
        ? await _unsaveArticle(
            UnsaveArticleParams(userId: userId, articleId: loaded.article.id))
        : await _saveArticle(
            SaveArticleParams(userId: userId, articleId: loaded.article.id));

    if (!result.isSuccess) {
      // Revert optimistic update
      emit(ArticleDetailLoaded(
        article: loaded.article,
        author: loaded.author,
        isSaved: previouslySaved,
        relatedArticles: loaded.relatedArticles,
        isDoneToday: loaded.isDoneToday,
      ));
      return false;
    }

    return true;
  }

  Future<bool> feedTortu(String userId, String categoryId) async {
    final current = state;
    if (current is! ArticleDetailLoaded) return false;
    if (current.isDoneToday) return false;

    final date = _todayDate();
    final tipResult = await _feedTortu(FeedTortuParams(
      userId: userId,
      articleId: current.article.id,
      categoryId: categoryId,
      date: date,
    ));
    if (tipResult.isFailure) return false;

    final swipeResult =
        await _recordFeedSwipe(RecordFeedSwipeParams(userId: userId));
    if (swipeResult.isFailure) return false;

    emit(ArticleDetailLoaded(
      article: current.article,
      author: current.author,
      isSaved: current.isSaved,
      relatedArticles: current.relatedArticles,
      isDoneToday: true,
    ));
    return true;
  }

  String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _mapErrorToMessage(Exception error) {
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' => 'No tienes permiso para ver este artículo',
        'not-found' => 'El artículo no existe',
        'unavailable' => 'Sin conexión. Inténtalo de nuevo',
        _ => 'Algo salió mal. Inténtalo de nuevo',
      };
    }
    return 'Algo salió mal. Inténtalo de nuevo';
  }
}
