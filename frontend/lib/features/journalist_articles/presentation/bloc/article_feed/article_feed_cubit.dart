import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../domain/entities/journalist_article.dart';
import '../../../domain/params/get_published_articles_params.dart';
import '../../../domain/use_cases/get_published_articles.dart';
import 'article_feed_state.dart';

/// Drives a feed of published articles.
///
/// Constructed with no [authorId] it is the general "community articles"
/// feed; constructed with one, it is "more articles from this journalist",
/// shown under an article's detail. It owns no business rule: every decision
/// is taken by [GetPublishedArticlesUseCase].
class ArticleFeedCubit extends Cubit<ArticleFeedState> {
  final GetPublishedArticlesUseCase _getPublishedArticles;

  final String? authorId;
  final String? excludeArticleId;

  /// Number of articles requested per page. Configurable so tests can exercise
  /// pagination without needing dozens of fixture articles.
  final int pageSize;

  /// Whether to show only what was published inside
  /// [GetPublishedArticlesParams.feedWindow].
  ///
  /// True for the community feed, which answers "what is new". False when the
  /// feed is scoped to one journalist: an author's page is their catalogue,
  /// and their work should not disappear from it after a week.
  final bool onlyRecent;

  ArticleFeedCubit(
    this._getPublishedArticles, {
    this.authorId,
    this.excludeArticleId,
    this.pageSize = 10,
    this.onlyRecent = true,
  }) : super(const ArticleFeedState());

  /// Loads the first page, replacing whatever was shown before.
  Future<void> loadFeed() async {
    emit(state.copyWith(status: ArticleFeedStatus.loading, clearError: true));

    final result = await _getPublishedArticles(_paramsFor(null));

    _emitPage(result, replace: true);
  }

  /// Appends the next page after the last article currently loaded.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(status: ArticleFeedStatus.loadingMore));

    final result = await _getPublishedArticles(
      _paramsFor(state.articles.isEmpty ? null : state.articles.last.id),
    );

    _emitPage(result, replace: false);
  }

  GetPublishedArticlesParams _paramsFor(String? startAfterArticleId) {
    if (onlyRecent) {
      return GetPublishedArticlesParams.recent(
        limit: pageSize,
        authorId: authorId,
        excludeArticleId: excludeArticleId,
        startAfterArticleId: startAfterArticleId,
      );
    }

    return GetPublishedArticlesParams(
      limit: pageSize,
      authorId: authorId,
      excludeArticleId: excludeArticleId,
      startAfterArticleId: startAfterArticleId,
    );
  }

  void _emitPage(
    DataState<List<JournalistArticleEntity>> result, {
    required bool replace,
  }) {
    if (result is DataSuccess<List<JournalistArticleEntity>>) {
      final page = result.data ?? const <JournalistArticleEntity>[];
      emit(state.copyWith(
        status: ArticleFeedStatus.success,
        articles: replace ? page : [...state.articles, ...page],
        hasMore: page.length == pageSize,
      ));
      return;
    }

    emit(state.copyWith(
      status: ArticleFeedStatus.failure,
      error: result.error,
    ));
  }
}
