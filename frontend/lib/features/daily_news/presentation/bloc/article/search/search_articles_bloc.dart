import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/search_articles.dart';

import 'search_articles_event.dart';
import 'search_articles_state.dart';

class SearchArticlesBloc
    extends Bloc<SearchArticlesEvent, SearchArticlesState> {
  final SearchArticlesUseCase _searchArticlesUseCase;
  StreamSubscription<DataState<List<ArticleEntity>>>? _subscription;

  SearchArticlesBloc(this._searchArticlesUseCase)
      : super(const SearchArticlesInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: restartable(),
    );
    on<SearchArticlesUpdated>(_onUpdated);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchArticlesState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      _subscription?.cancel();
      emit(const SearchArticlesInitial());
      return;
    }

    // Debounce: restartable() cancels this handler if a new event arrives
    // before the delay completes.
    await Future.delayed(const Duration(milliseconds: 300));

    emit(const SearchArticlesLoading());
    _subscription?.cancel();
    _subscription = _searchArticlesUseCase(params: query).listen(
      (dataState) => add(SearchArticlesUpdated(dataState)),
    );
  }

  void _onUpdated(
    SearchArticlesUpdated event,
    Emitter<SearchArticlesState> emit,
  ) {
    if (event.dataState is DataSuccess) {
      emit(SearchArticlesDone(event.dataState.data!));
    }
    if (event.dataState is DataFailed) {
      emit(SearchArticlesFailure(event.dataState.error!));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
