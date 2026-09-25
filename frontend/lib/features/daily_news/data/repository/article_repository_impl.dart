import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/data/data_sources/remote/current_user_data_source.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/cached_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import 'package:retrofit/retrofit.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  final CurrentUserDataSource _currentUserDataSource;
  ArticleRepositoryImpl(
      this._newsApiService, this._appDatabase, this._currentUserDataSource);

  /// Online, also keeps a copy of each section's first page on the phone;
  /// offline (or if NewsAPI fails), answers with that copy instead, marked
  /// with when it was saved. Screens never know which one they got.
  @override
  Future<DataState<NewsPage>> getNewsArticles(NewsQuery query) async {
    final result = await _fetchPage(
      () => _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: _apiCategory(query.category),
        page: query.page,
        pageSize: query.pageSize,
      ),
      query,
    );
    if (query.page != 1) return result;
    if (result is DataSuccess<NewsPage>) {
      await _saveOfflineCopy(query.category, result.data!.articles);
      return result;
    }
    final rateLimited =
        result is DataFailed && _isRateLimitError(result.error);
    return await _offlineCopy(query.category, isRateLimited: rateLimited) ??
        result;
  }

  // NewsAPI's own code for "you've used your free plan's daily requests" --
  // a different problem than not being able to reach it at all, and one
  // the offline banner shouldn't describe as a connection issue.
  bool _isRateLimitError(Object? error) {
    final body = error is DioException ? error.response?.data : null;
    return body is Map && body['code'] == 'rateLimited';
  }

  Future<void> _saveOfflineCopy(
    NewsCategory category,
    List<ArticleEntity> articles,
  ) async {
    if (articles.isEmpty) return;
    final savedAt = DateTime.now().millisecondsSinceEpoch;
    try {
      final dao = _appDatabase.cachedArticleDAO;
      await dao.deleteCategory(category.name);
      await dao.insertArticles([
        for (final (position, article) in articles.indexed)
          CachedArticleModel.fromEntity(
            article,
            category: category.name,
            position: position,
            savedAt: savedAt,
          ),
      ]);
    } catch (_) {
      // A copy that couldn't be saved only matters offline; the stories
      // just loaded are still fine to show.
    }
  }

  Future<DataState<NewsPage>?> _offlineCopy(
    NewsCategory category, {
    bool isRateLimited = false,
  }) async {
    final rows =
        await _appDatabase.cachedArticleDAO.getCachedArticles(category.name);
    if (rows.isEmpty) return null;
    return DataSuccess(NewsPage(
      articles: [for (final row in rows) row.toEntity()],
      hasMore: false,
      savedAt: DateTime.fromMillisecondsSinceEpoch(rows.first.savedAt),
      isRateLimited: isRateLimited,
    ));
  }

  @override
  Future<DataState<NewsPage>> searchArticles(SearchQuery query) {
    return _fetchPage(
      () => _newsApiService.searchArticles(
        apiKey: newsAPIKey,
        query: query.text.trim(),
        // Only where the reader can see it: matching anywhere in the full
        // text returned mostly stories that name the term in passing (a
        // search for "Messi" had 1 relevant result in 6; this way, 4).
        searchIn: 'title,description',
        language: query.languageCode,
        // Newest first, like the feed itself.
        sortBy: 'publishedAt',
        page: query.page,
        pageSize: query.pageSize,
      ),
      query,
    );
  }

  /// What the feed and search share: one NewsAPI request turned into a
  /// page of clean stories, or a failure.
  Future<DataState<NewsPage>> _fetchPage(
    Future<HttpResponse<List<ArticleModel>>> Function() request,
    PagedQuery query,
  ) async {
    try {
      final httpResponse = await request();
      if (httpResponse.response.statusCode != HttpStatus.ok) {
        return DataFailed(
          DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions,
          ),
        );
      }
      final models = httpResponse.data;
      return DataSuccess(NewsPage(
        // NewsAPI keeps withdrawn articles in its results as "[Removed]"
        // placeholders, with no text or image worth showing.
        articles: _toEntities(
            models.where((model) => model.title != '[Removed]').toList()),
        hasMore: _hasMorePages(httpResponse.response.data, query),
      ));
    } on DioException catch (e) {
      // The free plan serves at most 100 results per query; past that it
      // answers with an error, which to the reader simply means "no more".
      if (_isResultCapError(e)) {
        return const DataSuccess(NewsPage(articles: [], hasMore: false));
      }
      return DataFailed(e);
    }
  }

  String _apiCategory(NewsCategory category) => switch (category) {
        NewsCategory.top => 'general',
        NewsCategory.business => 'business',
        NewsCategory.technology => 'technology',
        NewsCategory.science => 'science',
        NewsCategory.health => 'health',
        NewsCategory.sports => 'sports',
        NewsCategory.entertainment => 'entertainment',
      };

  // From the response's totalResults, not by counting what came back:
  // NewsAPI sometimes returns fewer stories than asked for (18 of a
  // requested 20, with 36 in total) even when more pages exist.
  bool _hasMorePages(Object? body, PagedQuery query) {
    final total = body is Map ? body['totalResults'] : null;
    return total is int && query.page * query.pageSize < total;
  }

  bool _isResultCapError(DioException e) {
    final body = e.response?.data;
    return body is Map && body['code'] == 'maximumResultsReached';
  }

  // Saved articles are scoped to whoever's actually signed in -- otherwise
  // switching accounts on the same phone would show the previous account's
  // saved list right back, since the local table has no other way to tell
  // one person's saves apart from another's.
  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    final uid = await _currentUserDataSource.ensureSignedIn();
    return _toEntities(await _appDatabase.articleDAO.getArticles(uid));
  }

  List<ArticleEntity> _toEntities(List<ArticleModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  // Articles from the NewsAPI feed never carry a real `id` (see
  // ArticleModel.fromJson -- it never sets one), so Floor's declared
  // primary key (`id`) can't be trusted to identify "this article" once
  // it's been saved: SQLite auto-assigns a fresh id to every null-id
  // insert, even for the exact same article, and a delete keyed on a null
  // id matches nothing. `url` is the one field that actually, stably
  // identifies a specific article, so both methods below look articles up
  // by `url` instead of relying on `id`.
  @override
  Future<void> removeArticle(ArticleEntity article) async {
    final uid = await _currentUserDataSource.ensureSignedIn();
    final saved = await _appDatabase.articleDAO.getArticles(uid);
    final matches = saved.where((existing) => existing.url == article.url);
    if (matches.isEmpty) return;
    // Deletes the DB-sourced row (real id) that matches by url, not the
    // caller's own `article`, which may still be carrying a null id.
    await _appDatabase.articleDAO.deleteArticle(matches.first);
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    final uid = await _currentUserDataSource.ensureSignedIn();
    final saved = await _appDatabase.articleDAO.getArticles(uid);
    final alreadySaved = saved.any((existing) => existing.url == article.url);
    if (alreadySaved) return;
    await _appDatabase.articleDAO
        .insertArticle(ArticleModel.fromEntity(article, savedBy: uid));
  }

}