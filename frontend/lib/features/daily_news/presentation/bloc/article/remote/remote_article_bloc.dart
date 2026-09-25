import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

/// Kept as a Bloc with events, as the starter wrote it, while the features
/// built for this assignment use Cubits -- so the project shows both.
class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  static const pageSize = 20;

  final GetArticleUseCase _getArticleUseCase;

  // What each section already loaded: going back to it costs no request,
  // and NewsAPI's free plan only allows 100 a day.
  final _loaded = <NewsCategory, RemoteArticlesDone>{};

  RemoteArticlesBloc(this._getArticleUseCase)
      : super(const RemoteArticlesLoading(NewsCategory.top)) {
    on<GetArticles>(_onGetArticles);
    on<LoadMoreArticles>(_onLoadMore);
  }

  Future<void> _onGetArticles(
    GetArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    var outcome = RefreshOutcome.failed;
    try {
      outcome = await _loadCategory(event, emit);
    } finally {
      event.completer?.complete(outcome);
    }
  }

  Future<RefreshOutcome> _loadCategory(
    GetArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    final category = event.category;
    final cached = _loaded[category];
    if (cached != null && !event.refresh) {
      emit(cached);
      return RefreshOutcome.nothingNew;
    }
    // A refresh keeps the current list on screen under the pull indicator.
    if (cached == null) emit(RemoteArticlesLoading(category));

    final result = await _getArticleUseCase(
      params: NewsQuery(category: category, pageSize: pageSize),
    );
    final page = result is DataSuccess<NewsPage> ? result.data! : null;
    final isOfflineCopy = page?.isOfflineCopy ?? false;
    // Offline, what's already on screen is at least as fresh as the copy.
    if (isOfflineCopy && cached != null) {
      if (state.category == category) emit(cached);
      return page!.isRateLimited
          ? RefreshOutcome.rateLimited
          : RefreshOutcome.offline;
    }
    final loaded = page == null
        ? null
        : RemoteArticlesDone(
            category,
            articles: page.articles,
            hasReachedEnd: !page.hasMore,
            savedAt: page.savedAt,
            isRateLimited: page.isRateLimited,
          );
    // Not an offline copy, though: coming back to this section should try
    // the network again rather than keep showing the copy.
    if (loaded != null && !isOfflineCopy) _loaded[category] = loaded;
    // The reader may have moved to another section while this loaded.
    if (state.category == category) {
      emit(loaded ?? cached ?? RemoteArticlesError(category, result.error));
    }
    if (loaded == null) return RefreshOutcome.failed;
    if (isOfflineCopy) {
      return page!.isRateLimited
          ? RefreshOutcome.rateLimited
          : RefreshOutcome.offline;
    }
    return _hasNewStories(before: cached, after: loaded)
        ? RefreshOutcome.newStories
        : RefreshOutcome.nothingNew;
  }

  bool _hasNewStories({
    required RemoteArticlesDone? before,
    required RemoteArticlesDone after,
  }) {
    if (before == null) return after.articles.isNotEmpty;
    final seen = {for (final article in before.articles) article.url};
    return after.articles.any((article) => !seen.contains(article.url));
  }

  Future<void> _onLoadMore(
    LoadMoreArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    final current = state;
    if (current is! RemoteArticlesDone ||
        current.hasReachedEnd ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));

    final result = await _getArticleUseCase(
      params: NewsQuery(
        category: current.category,
        page: current.page + 1,
        pageSize: pageSize,
      ),
    );
    // On failure the list just stops loading; scrolling again retries.
    final next = result is DataSuccess<NewsPage>
        ? _appendPage(current, result.data!)
        : current;
    _loaded[current.category] = next;
    if (state.category == current.category) emit(next);
  }

  RemoteArticlesDone _appendPage(RemoteArticlesDone current, NewsPage page) {
    // Headlines shift while you scroll, so a story can show up on two pages.
    final seen = {for (final article in current.articles) article.url};
    final fresh = <ArticleEntity>[
      for (final article in page.articles)
        if (seen.add(article.url)) article,
    ];
    return current.copyWith(
      articles: [...current.articles, ...fresh],
      page: current.page + 1,
      hasReachedEnd: !page.hasMore,
      isLoadingMore: false,
    );
  }
}
