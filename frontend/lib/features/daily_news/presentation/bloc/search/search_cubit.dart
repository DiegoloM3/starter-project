import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_recent_searches.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_search.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_search.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/search_articles.dart';

import 'search_state.dart';

/// Searches NewsAPI when the reader submits, not on every keystroke: each
/// search costs one of the free plan's 100 requests a day.
class SearchCubit extends Cubit<SearchState> {
  static const pageSize = 20;

  final SearchArticlesUseCase _searchArticlesUseCase;
  final GetRecentSearchesUseCase _getRecentSearchesUseCase;
  final SaveSearchUseCase _saveSearchUseCase;
  final RemoveSearchUseCase _removeSearchUseCase;

  // The language results come in; set by the screen from the app's locale.
  String _languageCode = 'en';

  SearchCubit(
    this._searchArticlesUseCase,
    this._getRecentSearchesUseCase,
    this._saveSearchUseCase,
    this._removeSearchUseCase,
  ) : super(const SearchIdle());

  /// Back to the start: the box is empty and the recent searches show.
  Future<void> showHistory() async {
    final history = await _getRecentSearchesUseCase();
    if (isClosed) return;
    emit(SearchIdle(history: history));
  }

  Future<void> removeFromHistory(String text) async {
    await _removeSearchUseCase(params: text);
    if (state is SearchIdle) await showHistory();
  }

  Future<void> search(String text, {required String languageCode}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _languageCode = languageCode;
    emit(SearchLoading(trimmed));
    await _saveSearchUseCase(params: trimmed);
    final result = await _searchArticlesUseCase(
      params: SearchQuery(
        text: trimmed,
        languageCode: languageCode,
        pageSize: pageSize,
      ),
    );
    // A newer search may have started while this one was on its way.
    if (!_isStillShowing(trimmed)) return;
    emit(result is DataSuccess<NewsPage>
        ? SearchResults(
            trimmed,
            articles: result.data!.articles,
            hasReachedEnd: !result.data!.hasMore,
          )
        : SearchError(trimmed));
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! SearchResults ||
        current.hasReachedEnd ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    final result = await _searchArticlesUseCase(
      params: SearchQuery(
        text: current.text,
        languageCode: _languageCode,
        page: current.page + 1,
        pageSize: pageSize,
      ),
    );
    if (!_isStillShowing(current.text)) return;
    // On failure the list just stops loading; scrolling again retries.
    emit(result is DataSuccess<NewsPage>
        ? _appendPage(current, result.data!)
        : current);
  }

  bool _isStillShowing(String text) {
    final current = state;
    return switch (current) {
      SearchLoading() => current.text == text,
      SearchResults() => current.text == text,
      _ => false,
    };
  }

  SearchResults _appendPage(SearchResults current, NewsPage page) {
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
