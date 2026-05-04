import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_community_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/page_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_fitness_articles.dart';
import 'package:news_app_clean_architecture/features/recommendations/domain/use_cases/recommend_for_user.dart';
import 'package:news_app_clean_architecture/features/search/domain/params/semantic_search_params.dart';
import 'package:news_app_clean_architecture/features/search/domain/use_cases/semantic_search.dart';
import 'feed_event.dart';
import 'feed_state.dart';

const int _kPageSize = 20;
const int _kCommunityPageSize = 20;

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetArticleUseCase _getNewsArticles;
  final GetFitnessArticlesUseCase _getFitnessArticles;
  final WatchCommunityFeedUseCase _watchCommunityFeed;
  final SemanticSearchUseCase _semanticSearch;
  final RecommendForUserUseCase _recommendForUser;

  StreamSubscription<List<JournalistArticleEntity>>? _communitySub;
  Timer? _searchDebounce;

  FeedBloc(
    this._getNewsArticles,
    this._getFitnessArticles,
    this._watchCommunityFeed,
    this._semanticSearch,
    this._recommendForUser,
  ) : super(const FeedState()) {
    on<LoadFeedEvent>(_onLoad);
    on<LoadMoreEvent>(_onLoadMore);
    on<FilterChangedEvent>(_onFilterChanged);
    on<RecommendationsLoadedEvent>((e, emit) => emit(state.copyWith(
          recommendations: e.articles,
          isLoadingRecommendations: false,
          error: null,
        )));
    on<RecommendationsFailedEvent>((e, emit) => emit(state.copyWith(
          isLoadingRecommendations: false,
          error: e.error,
        )));
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<SearchExecutedEvent>(_onSearchExecuted);
    on<SearchSucceededEvent>((e, emit) => emit(state.copyWith(
          searchResults: e.articleIds,
          searchFallbackActive: false,
          error: null,
        )));
    on<SearchFailedEvent>((e, emit) => emit(state.copyWith(
          searchResults: null,
          searchFallbackActive: true,
          error: e.error,
        )));
    on<NewsFeedUpdatedEvent>(
        (e, emit) => emit(state.copyWith(newsArticles: e.articles)));
    on<NewsFeedAppendedEvent>((e, emit) {
      final merged = [...state.rawNewsArticles, ...e.articles];
      emit(state.copyWith(newsArticles: merged));
    });
    on<FitnessFeedUpdatedEvent>(
        (e, emit) => emit(state.copyWith(fitnessArticles: e.articles)));
    on<FitnessFeedAppendedEvent>((e, emit) {
      final merged = [...state.rawFitnessArticles, ...e.articles];
      emit(state.copyWith(fitnessArticles: merged));
    });
    on<CommunityFeedUpdatedEvent>(
        (e, emit) => emit(state.copyWith(communityArticles: e.articles)));
    on<CommunityFeedFailedEvent>(
        (e, emit) => emit(state.copyWith(error: e.error)));
  }

  Future<void> _onFilterChanged(
    FilterChangedEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter));
    if (event.filter != FeedFilter.forYou) return;

    // Refresh recommendations every time the user lands on For You — keeps
    // the list fresh when saves change between visits.
    emit(state.copyWith(isLoadingRecommendations: true, error: null));
    final result = await _recommendForUser.call(params: 20);
    if (result is DataSuccess<List<ArticleEntity>>) {
      add(RecommendationsLoadedEvent(result.data ?? const []));
    } else if (result is DataFailed<List<ArticleEntity>>) {
      add(RecommendationsFailedEvent(result.error!));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<FeedState> emit,
  ) {
    final trimmed = event.query.trim();
    emit(state.copyWith(searchQuery: event.query));

    _searchDebounce?.cancel();
    if (trimmed.isEmpty) {
      // Clear active search; revert to filter-chip behavior.
      emit(state.copyWith(
        searchResults: null,
        searchFallbackActive: false,
        error: null,
      ));
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      add(SearchExecutedEvent(trimmed));
    });
  }

  Future<void> _onSearchExecuted(
    SearchExecutedEvent event,
    Emitter<FeedState> emit,
  ) async {
    final result = await _semanticSearch.call(
      params: SemanticSearchParams(query: event.query, limit: 20),
    );
    if (result is DataSuccess<List<String>>) {
      add(SearchSucceededEvent(result.data ?? const []));
    } else if (result is DataFailed<List<String>>) {
      add(SearchFailedEvent(result.error!));
    }
  }

  Future<void> _onLoad(
    LoadFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      newsPage: 1,
      fitnessPage: 1,
      communityLimit: _kCommunityPageSize,
      hasMoreNews: true,
      hasMoreFitness: true,
    ));

    final results = await Future.wait([
      _getNewsArticles.call(
          params: const PageParams(page: 1, pageSize: _kPageSize)),
      _getFitnessArticles.call(
          params: const PageParams(page: 1, pageSize: _kPageSize)),
    ]);
    final newsResult = results[0];
    final fitnessResult = results[1];
    if (newsResult is DataSuccess<List<ArticleEntity>>) {
      final raw = newsResult.data ?? const <ArticleEntity>[];
      add(NewsFeedUpdatedEvent(_filterComplete(raw)));
      if (raw.length < _kPageSize) {
        emit(state.copyWith(hasMoreNews: false));
      }
    }
    if (fitnessResult is DataSuccess<List<ArticleEntity>>) {
      final raw = fitnessResult.data ?? const <ArticleEntity>[];
      add(FitnessFeedUpdatedEvent(_filterComplete(raw)));
      if (raw.length < _kPageSize) {
        emit(state.copyWith(hasMoreFitness: false));
      }
    }

    emit(state.copyWith(isLoading: false));

    _communitySub?.cancel();
    _communitySub =
        _watchCommunityFeed.call(params: state.communityLimit).listen(
      (articles) => add(CommunityFeedUpdatedEvent(articles)),
      onError: (Object e, StackTrace st) =>
          add(CommunityFeedFailedEvent(_mapStreamError(e, st))),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true, error: null));

    switch (state.filter) {
      case FeedFilter.news:
        await _loadMoreNews(emit);
      case FeedFilter.fitnessNews:
        await _loadMoreFitness(emit);
      case FeedFilter.community:
        _bumpCommunityLimit(emit);
      case FeedFilter.all:
        await Future.wait([
          if (state.hasMoreNews) _loadMoreNews(emit),
          if (state.hasMoreFitness) _loadMoreFitness(emit),
        ]);
        _bumpCommunityLimit(emit);
      case FeedFilter.forYou:
        // Recommendation list is fixed-size from a single API call; no
        // pagination semantics yet.
        break;
    }

    emit(state.copyWith(isLoadingMore: false));
  }

  Future<void> _loadMoreNews(Emitter<FeedState> emit) async {
    if (!state.hasMoreNews) return;
    final nextPage = state.newsPage + 1;
    final result = await _getNewsArticles.call(
      params: PageParams(page: nextPage, pageSize: _kPageSize),
    );
    if (result is DataSuccess<List<ArticleEntity>>) {
      final raw = result.data ?? const <ArticleEntity>[];
      add(NewsFeedAppendedEvent(_filterComplete(raw)));
      emit(state.copyWith(
        newsPage: nextPage,
        hasMoreNews: raw.length >= _kPageSize,
      ));
    }
  }

  Future<void> _loadMoreFitness(Emitter<FeedState> emit) async {
    if (!state.hasMoreFitness) return;
    final nextPage = state.fitnessPage + 1;
    final result = await _getFitnessArticles.call(
      params: PageParams(page: nextPage, pageSize: _kPageSize),
    );
    if (result is DataSuccess<List<ArticleEntity>>) {
      final raw = result.data ?? const <ArticleEntity>[];
      add(FitnessFeedAppendedEvent(_filterComplete(raw)));
      emit(state.copyWith(
        fitnessPage: nextPage,
        hasMoreFitness: raw.length >= _kPageSize,
      ));
    }
  }

  void _bumpCommunityLimit(Emitter<FeedState> emit) {
    final newLimit = state.communityLimit + _kCommunityPageSize;
    emit(state.copyWith(communityLimit: newLimit));
    _communitySub?.cancel();
    _communitySub = _watchCommunityFeed.call(params: newLimit).listen(
      (articles) => add(CommunityFeedUpdatedEvent(articles)),
      onError: (Object e, StackTrace st) =>
          add(CommunityFeedFailedEvent(_mapStreamError(e, st))),
    );
  }

  /// Drops NewsAPI articles that are unsafe to render: missing or "[Removed]"
  /// title/content, or a thumbnail URL that isn't a syntactically valid http(s)
  /// link. Broken images that are syntactically valid still fall through and
  /// are handled by `Image.network`'s `errorBuilder` at render time.
  List<ArticleEntity> _filterComplete(List<ArticleEntity> articles) {
    return articles.where(_isCompleteNewsArticle).toList();
  }

  static bool _isCompleteNewsArticle(ArticleEntity a) {
    final title = a.title;
    if (title == null || title.isEmpty || title == '[Removed]') return false;
    final description = a.description;
    if (description == null || description.isEmpty) return false;
    final url = a.urlToImage;
    if (url == null || url.isEmpty) return false;
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme) return false;
    if (parsed.scheme != 'http' && parsed.scheme != 'https') return false;
    return true;
  }

  AppException _mapStreamError(Object e, StackTrace st) {
    if (e is AppException) return e;
    return FirestoreException(
      message: e.toString(),
      cause: e,
      stackTrace: st,
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    _communitySub?.cancel();
    return super.close();
  }
}
