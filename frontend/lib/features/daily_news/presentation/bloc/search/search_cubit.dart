import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search_articles.dart';

part 'search_state.dart';

/// Full-text search across both sources. Typing is debounced so the
/// provider is asked once per pause, not once per keystroke; submitting a
/// query remembers it in the recent list.
class SearchCubit extends Cubit<SearchState> {
  final SearchArticlesUseCase _searchArticles;
  final Duration _debounce;
  Timer? _timer;
  int _requestCount = 0;

  static const int maxRecent = 8;

  SearchCubit(this._searchArticles, {Duration debounce = const Duration(milliseconds: 300)})
      : _debounce = debounce,
        super(const SearchState());

  void queryChanged(String value) {
    _timer?.cancel();
    if (value.trim().isEmpty) {
      _requestCount++;
      emit(state.copyWith(query: value, status: SearchStatus.idle, results: const []));
      return;
    }
    emit(state.copyWith(query: value));
    _timer = Timer(_debounce, () => search(value));
  }

  /// Runs the search now (submit, recent tap, topic chip) and records it.
  Future<void> search(String value) async {
    _timer?.cancel();
    final query = value.trim();
    if (query.isEmpty) return;

    final request = ++_requestCount;
    emit(state.copyWith(
      query: value,
      status: SearchStatus.loading,
      recent: [query, ...state.recent.where((r) => r.toLowerCase() != query.toLowerCase())]
          .take(maxRecent)
          .toList(),
    ));

    final result = await _searchArticles(query);
    if (isClosed || request != _requestCount) return;

    emit(switch (result) {
      DataSuccess(:final data) => state.copyWith(status: SearchStatus.results, results: data.articles),
      DataFailed(:final failure) => state.copyWith(status: SearchStatus.failure, failure: failure),
    });
  }

  void clear() {
    _timer?.cancel();
    _requestCount++;
    emit(state.copyWith(query: '', status: SearchStatus.idle, results: const []));
  }

  void clearRecent() => emit(state.copyWith(recent: const []));

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
