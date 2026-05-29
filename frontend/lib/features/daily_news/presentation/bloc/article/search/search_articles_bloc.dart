import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_feed_articles.dart';

import 'search_articles_event.dart';
import 'search_articles_state.dart';

const _searchDebounceDuration = Duration(milliseconds: 300);

/// Debounces incoming events, then delegates to [restartable] so only the
/// latest event is processed when keystrokes arrive in rapid succession.
EventTransformer<E> _debounceRestartable<E>(Duration duration) {
  return (events, mapper) =>
      restartable<E>().call(_debounce(events, duration), mapper);
}

Stream<E> _debounce<E>(Stream<E> events, Duration duration) {
  Timer? timer;
  late final StreamController<E> controller;
  StreamSubscription<E>? subscription;
  E? lastEvent;
  var hasPending = false;

  void emitPending() {
    if (!hasPending) return;
    hasPending = false;
    final event = lastEvent as E;
    lastEvent = null;
    controller.add(event);
  }

  controller = StreamController<E>(
    onListen: () {
      subscription = events.listen(
        (event) {
          lastEvent = event;
          hasPending = true;
          timer?.cancel();
          timer = Timer(duration, emitPending);
        },
        onError: controller.addError,
        onDone: () {
          timer?.cancel();
          emitPending();
          controller.close();
        },
      );
    },
    onCancel: () {
      timer?.cancel();
      return subscription?.cancel();
    },
  );

  return controller.stream;
}

/// Search is intentionally performed client-side over the live feed.
///
/// [GetFeedArticlesUseCase] already streams every published Firestore article
/// (the feed query is unbounded) merged with the News API headlines, so
/// filtering the in-memory list covers the full searchable set instantly and
/// without issuing a new Firestore query per keystroke. A server-side search
/// use case would be strictly narrower (Firestore only, no News API) and more
/// expensive, so it is deliberately not used here.
class SearchArticlesBloc
    extends Bloc<SearchArticlesEvent, SearchArticlesState> {
  final GetFeedArticlesUseCase _getFeedArticlesUseCase;
  StreamSubscription<DataState<List<ArticleEntity>>>? _subscription;
  List<ArticleEntity> _allArticles = [];
  String _currentQuery = '';

  SearchArticlesBloc(this._getFeedArticlesUseCase)
      : super(const SearchArticlesLoading()) {
    on<SearchFeedLoaded>(_onFeedLoaded);
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: _debounceRestartable(_searchDebounceDuration),
    );
    on<_SearchFeedError>(_onFeedError);
    on<SearchRetryRequested>(_onRetryRequested);
    _subscribeFeed();
  }

  void _subscribeFeed() {
    _subscription?.cancel();
    _subscription = _getFeedArticlesUseCase().listen(
      (dataState) {
        if (dataState is DataSuccess && dataState.data != null) {
          add(SearchFeedLoaded(dataState.data!));
        } else if (dataState is DataFailed && dataState.error != null) {
          add(_SearchFeedError(dataState.error!));
        }
      },
      onError: (Object error) {
        add(_SearchFeedError(
          AppException(message: error.toString(), code: 'stream_error'),
        ));
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

  void _onRetryRequested(
    SearchRetryRequested event,
    Emitter<SearchArticlesState> emit,
  ) {
    emit(const SearchArticlesLoading());
    _subscribeFeed();
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

class SearchRetryRequested extends SearchArticlesEvent {
  const SearchRetryRequested();
}
