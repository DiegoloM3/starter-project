import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_feed_articles.dart';

import 'search_articles_event.dart';
import 'search_articles_state.dart';

class SearchArticlesBloc
    extends Bloc<SearchArticlesEvent, SearchArticlesState> {
  final GetFeedArticlesUseCase _getFeedArticlesUseCase;
  StreamSubscription<DataState<List<ArticleEntity>>>? _subscription;
  List<ArticleEntity> _allArticles = [];
  String _currentQuery = '';

  SearchArticlesBloc(this._getFeedArticlesUseCase)
      : super(const SearchArticlesLoading()) {
    on<SearchFeedLoaded>(_onFeedLoaded);
    on<SearchQueryChanged>(_onQueryChanged);
    on<_SearchFeedError>(_onFeedError);
    _subscribeFeed();
  }

  void _subscribeFeed() {
    _subscription = _getFeedArticlesUseCase().listen(
      (dataState) {
        if (dataState is DataSuccess && dataState.data != null) {
          add(SearchFeedLoaded(dataState.data!));
        } else if (dataState is DataFailed && dataState.error != null) {
          add(_SearchFeedError(dataState.error!));
        }
      },
    );
  }

  void _onFeedLoaded(
    SearchFeedLoaded event,
    Emitter<SearchArticlesState> emit,
  ) {
    _allArticles = event.articles;
    emit(SearchArticlesDone(_filterByQuery(_currentQuery)));
  }

  void _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchArticlesState> emit,
  ) {
    _currentQuery = event.query.trim();
    emit(SearchArticlesDone(_filterByQuery(_currentQuery)));
  }

  void _onFeedError(
    _SearchFeedError event,
    Emitter<SearchArticlesState> emit,
  ) {
    emit(SearchArticlesFailure(event.error));
  }

  List<ArticleEntity> _filterByQuery(String query) {
    if (query.isEmpty) return _allArticles;
    final lower = query.toLowerCase();
    return _allArticles
        .where((a) =>
            (a.title?.toLowerCase().contains(lower) ?? false) ||
            (a.description?.toLowerCase().contains(lower) ?? false))
        .toList();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _SearchFeedError extends SearchArticlesEvent {
  final AppException error;

  const _SearchFeedError(this.error);
}
