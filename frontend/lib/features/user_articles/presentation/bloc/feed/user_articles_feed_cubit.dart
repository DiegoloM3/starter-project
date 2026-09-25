import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_user_articles_usecase.dart';

import 'user_articles_feed_state.dart';

class UserArticlesFeedCubit extends Cubit<UserArticlesFeedState> {
  final GetUserArticlesUseCase _getUserArticlesUseCase;

  static const _pageSize = 10;

  UserArticlesFeedCubit(this._getUserArticlesUseCase)
      : super(const UserArticlesFeedLoading());

  Future<void> loadArticles() async {
    emit(const UserArticlesFeedLoading());
    final result = await _getUserArticlesUseCase(
      params: const GetUserArticlesParams(limit: _pageSize),
    );
    if (result is DataSuccess<List<UserArticleEntity>>) {
      final articles = result.data!;
      emit(UserArticlesFeedLoaded(
        articles,
        hasMore: articles.length == _pageSize,
      ));
    } else {
      emit(UserArticlesFeedError(result.error?.toString() ?? 'Unknown error'));
    }
  }

  /// Fetches the next page and appends it. A no-op if there's nothing more,
  /// or a load is already in flight -- safe to call from a scroll listener
  /// that may fire more than once before the first request resolves.
  Future<void> loadMore() async {
    final current = state;
    if (current is! UserArticlesFeedLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getUserArticlesUseCase(
      params: GetUserArticlesParams(
        limit: _pageSize,
        startAfter: current.articles.last.createdAt,
      ),
    );
    if (result is DataSuccess<List<UserArticleEntity>>) {
      final newArticles = result.data!;
      emit(UserArticlesFeedLoaded(
        [...current.articles, ...newArticles],
        hasMore: newArticles.length == _pageSize,
      ));
    } else {
      // Keep what's already on screen; just stop showing the spinner so the
      // user can retry by scrolling again instead of losing the loaded page.
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
