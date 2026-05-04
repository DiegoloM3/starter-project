import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/feed/domain/entities/feed_item.dart';

enum FeedFilter { all, forYou, fitnessNews, news, community }

final class FeedState extends Equatable {
  final List<ArticleEntity> _newsArticles;
  final List<ArticleEntity> _fitnessArticles;
  final List<JournalistArticleEntity> _communityArticles;
  final FeedFilter filter;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMore;
  final int newsPage;
  final int fitnessPage;
  final int communityLimit;
  final bool hasMoreNews;
  final bool hasMoreFitness;
  final AppException? error;
  final List<String>? searchResults;
  final bool searchFallbackActive;
  final List<ArticleEntity>? recommendations;
  final bool isLoadingRecommendations;

  const FeedState({
    List<ArticleEntity> newsArticles = const [],
    List<ArticleEntity> fitnessArticles = const [],
    List<JournalistArticleEntity> communityArticles = const [],
    this.filter = FeedFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.newsPage = 1,
    this.fitnessPage = 1,
    this.communityLimit = 20,
    this.hasMoreNews = true,
    this.hasMoreFitness = true,
    this.error,
    this.searchResults,
    this.searchFallbackActive = false,
    this.recommendations,
    this.isLoadingRecommendations = false,
  })  : _newsArticles = newsArticles,
        _fitnessArticles = fitnessArticles,
        _communityArticles = communityArticles;

  /// Read-only access to the raw news list for pagination append operations.
  List<ArticleEntity> get rawNewsArticles => List.unmodifiable(_newsArticles);

  /// Read-only access to the raw fitness list for pagination append operations.
  List<ArticleEntity> get rawFitnessArticles =>
      List.unmodifiable(_fitnessArticles);

  List<FeedItem> get items {
    // Active search: hybrid path. Community articles come from semantic
    // search (back-end vector match); NewsAPI articles fall back to
    // client-side substring on title/description because they're external
    // and don't carry embeddings. Both contribute to the same result list.
    if (searchResults != null) {
      final results = <FeedItem>[];

      final byId = {for (final a in _communityArticles) a.id: a};
      for (final id in searchResults!) {
        final article = byId[id];
        if (article != null) results.add(JournalistFeedItem(article));
      }

      final q = searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        bool matches(ArticleEntity a) =>
            (a.title?.toLowerCase().contains(q) ?? false) ||
            (a.description?.toLowerCase().contains(q) ?? false);
        results.addAll(_newsArticles.where(matches).map(NewsApiFeedItem.new));
        results
            .addAll(_fitnessArticles.where(matches).map(NewsApiFeedItem.new));
      }

      return results;
    }

    // Filter-chip path (no active search).
    final filtered = <FeedItem>[];

    switch (filter) {
      case FeedFilter.all:
        filtered.addAll(_fitnessArticles.map(NewsApiFeedItem.new));
        filtered.addAll(_newsArticles.map(NewsApiFeedItem.new));
        filtered.addAll(_communityArticles.map(JournalistFeedItem.new));
      case FeedFilter.forYou:
        // Server-ranked by similarity — preserve that order, do NOT sort
        // by publishedAt below.
        return (recommendations ?? const <ArticleEntity>[])
            .map(NewsApiFeedItem.new)
            .toList();
      case FeedFilter.fitnessNews:
        filtered.addAll(_fitnessArticles.map(NewsApiFeedItem.new));
      case FeedFilter.news:
        filtered.addAll(_newsArticles.map(NewsApiFeedItem.new));
      case FeedFilter.community:
        filtered.addAll(_communityArticles.map(JournalistFeedItem.new));
    }

    filtered.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    // Fallback when semantic search itself failed (callable unreachable,
    // rate-limited, unauthenticated). Substring across the entire visible
    // feed keeps the feature usable on degraded backends.
    if (searchFallbackActive && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      return filtered.where((i) => i.title.toLowerCase().contains(q)).toList();
    }

    return filtered;
  }

  FeedState copyWith({
    List<ArticleEntity>? newsArticles,
    List<ArticleEntity>? fitnessArticles,
    List<JournalistArticleEntity>? communityArticles,
    FeedFilter? filter,
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingMore,
    int? newsPage,
    int? fitnessPage,
    int? communityLimit,
    bool? hasMoreNews,
    bool? hasMoreFitness,
    Object? error = _sentinel,
    Object? searchResults = _sentinel,
    bool? searchFallbackActive,
    Object? recommendations = _sentinel,
    bool? isLoadingRecommendations,
  }) {
    return FeedState(
      newsArticles: newsArticles ?? _newsArticles,
      fitnessArticles: fitnessArticles ?? _fitnessArticles,
      communityArticles: communityArticles ?? _communityArticles,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      newsPage: newsPage ?? this.newsPage,
      fitnessPage: fitnessPage ?? this.fitnessPage,
      communityLimit: communityLimit ?? this.communityLimit,
      hasMoreNews: hasMoreNews ?? this.hasMoreNews,
      hasMoreFitness: hasMoreFitness ?? this.hasMoreFitness,
      error: error == _sentinel ? this.error : error as AppException?,
      searchResults: searchResults == _sentinel
          ? this.searchResults
          : searchResults as List<String>?,
      searchFallbackActive: searchFallbackActive ?? this.searchFallbackActive,
      recommendations: recommendations == _sentinel
          ? this.recommendations
          : recommendations as List<ArticleEntity>?,
      isLoadingRecommendations:
          isLoadingRecommendations ?? this.isLoadingRecommendations,
    );
  }

  @override
  List<Object?> get props => [
        _newsArticles,
        _fitnessArticles,
        _communityArticles,
        filter,
        searchQuery,
        isLoading,
        isLoadingMore,
        newsPage,
        fitnessPage,
        communityLimit,
        hasMoreNews,
        hasMoreFitness,
        error,
        searchResults,
        searchFallbackActive,
        recommendations,
        isLoadingRecommendations,
      ];
}

const _sentinel = Object();
