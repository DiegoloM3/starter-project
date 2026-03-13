import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/resources/data_state.dart';
import '../../../domain/entities/user_article.dart';
import '../../../domain/usecases/delete_article.dart';
import '../../../domain/usecases/get_published_articles.dart';
import '../../../domain/usecases/get_user_articles.dart';
import '../../../domain/usecases/publish_article.dart';
import '../../../domain/usecases/get_articles_by_category.dart';
import 'user_articles_event.dart';
import 'user_articles_state.dart';

class UserArticlesBloc extends Bloc<UserArticlesEvent, UserArticlesState> {
  final GetUserArticlesUseCase _getUserArticlesUseCase;
  final GetPublishedArticlesUseCase _getPublishedArticlesUseCase;
  final GetArticlesByCategoryUseCase _getArticlesByCategoryUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  final PublishArticleUseCase _publishArticleUseCase;

  String? _currentUserId;

  UserArticlesBloc({
    required GetUserArticlesUseCase getUserArticlesUseCase,
    required GetPublishedArticlesUseCase getPublishedArticlesUseCase,
    required GetArticlesByCategoryUseCase getArticlesByCategoryUseCase,
    required DeleteArticleUseCase deleteArticleUseCase,
    required PublishArticleUseCase publishArticleUseCase,
  })  : _getUserArticlesUseCase = getUserArticlesUseCase,
        _getPublishedArticlesUseCase = getPublishedArticlesUseCase,
        _getArticlesByCategoryUseCase = getArticlesByCategoryUseCase,
        _deleteArticleUseCase = deleteArticleUseCase,
        _publishArticleUseCase = publishArticleUseCase,
        super(const UserArticlesInitial()) {
    on<LoadUserArticles>(_onLoadUserArticles);
    on<LoadPublishedArticles>(_onLoadPublishedArticles);
    on<LoadArticlesByCategory>(_onLoadArticlesByCategory);
    on<RefreshUserArticles>(_onRefreshUserArticles);
    on<FilterArticles>(_onFilterArticles);
    on<DeleteArticle>(_onDeleteArticle);
    on<PublishArticle>(_onPublishArticle);
    on<UnpublishArticle>(_onUnpublishArticle);
  }

  Future<void> _onLoadUserArticles(
    LoadUserArticles event,
    Emitter<UserArticlesState> emit,
  ) async {
    emit(const UserArticlesLoading());
    _currentUserId = event.userId;

    final dataState = await _getUserArticlesUseCase(params: event.userId);

    if (dataState is DataSuccess && dataState.data != null) {
      final articles = dataState.data!;
      final publishedCount = articles.where((a) => !a.isDraft).length;
      final draftsCount = articles.where((a) => a.isDraft).length;
      // Default to published filter (first tab)
      final filteredArticles = articles.where((a) => !a.isDraft).toList();

      emit(UserArticlesLoaded(
        articles: articles,
        filteredArticles: filteredArticles,
        currentFilter: ArticleFilter.published,
        publishedCount: publishedCount,
        draftsCount: draftsCount,
      ));
    } else {
      emit(UserArticlesError(
        message: dataState.error?.toString() ?? 'Failed to load articles',
      ));
    }
  }

  Future<void> _onLoadPublishedArticles(
    LoadPublishedArticles event,
    Emitter<UserArticlesState> emit,
  ) async {
    emit(const UserArticlesLoading());

    final dataState = await _getPublishedArticlesUseCase();

    if (dataState is DataSuccess && dataState.data != null) {
      final articles = dataState.data!;
      emit(UserArticlesLoaded(
        articles: articles,
        filteredArticles: articles,
        publishedCount: articles.length,
        draftsCount: 0,
      ));
    } else {
      emit(UserArticlesError(
        message: dataState.error?.toString() ?? 'Failed to load articles',
      ));
    }
  }

  Future<void> _onLoadArticlesByCategory(
    LoadArticlesByCategory event,
    Emitter<UserArticlesState> emit,
  ) async {
    emit(const UserArticlesLoading());

    final dataState =
        await _getArticlesByCategoryUseCase(params: event.category);

    if (dataState is DataSuccess && dataState.data != null) {
      final articles = dataState.data!;
      emit(UserArticlesLoaded(
        articles: articles,
        filteredArticles: articles,
        publishedCount: articles.length,
        draftsCount: 0,
      ));
    } else {
      emit(UserArticlesError(
        message: dataState.error?.toString() ?? 'Failed to load articles',
      ));
    }
  }

  Future<void> _onRefreshUserArticles(
    RefreshUserArticles event,
    Emitter<UserArticlesState> emit,
  ) async {
    if (_currentUserId == null) return;

    final dataState = await _getUserArticlesUseCase(params: _currentUserId!);

    if (dataState is DataSuccess && dataState.data != null) {
      final articles = dataState.data!;
      final publishedCount = articles.where((a) => !a.isDraft).length;
      final draftsCount = articles.where((a) => a.isDraft).length;

      final currentFilter = state.currentFilter;
      final filteredArticles = _applyFilter(articles, currentFilter);

      emit(UserArticlesLoaded(
        articles: articles,
        filteredArticles: filteredArticles,
        currentFilter: currentFilter,
        publishedCount: publishedCount,
        draftsCount: draftsCount,
      ));
    }
  }

  void _onFilterArticles(
    FilterArticles event,
    Emitter<UserArticlesState> emit,
  ) {
    if (state is UserArticlesLoaded) {
      final currentState = state as UserArticlesLoaded;
      final filteredArticles =
          _applyFilter(currentState.articles!, event.filter);

      emit(currentState.copyWith(
        filteredArticles: filteredArticles,
        currentFilter: event.filter,
      ));
    }
  }

  List<UserArticleEntity> _applyFilter(
    List<UserArticleEntity> articles,
    ArticleFilter filter,
  ) {
    switch (filter) {
      case ArticleFilter.published:
        return articles.where((a) => !a.isDraft).toList();
      case ArticleFilter.drafts:
        return articles.where((a) => a.isDraft).toList();
      case ArticleFilter.all:
        return articles;
    }
  }

  Future<void> _onDeleteArticle(
    DeleteArticle event,
    Emitter<UserArticlesState> emit,
  ) async {
    if (state is! UserArticlesLoaded) return;
    final currentState = state as UserArticlesLoaded;

    emit(UserArticlesActionInProgress(
      actionMessage: 'Deleting article...',
      articles: currentState.articles,
      filteredArticles: currentState.filteredArticles,
      currentFilter: currentState.currentFilter,
    ));

    final dataState = await _deleteArticleUseCase(params: event.articleId);

    if (dataState is DataSuccess) {
      // Remove the article from local list
      final updatedArticles =
          currentState.articles!.where((a) => a.id != event.articleId).toList();
      final filteredArticles =
          _applyFilter(updatedArticles, currentState.currentFilter);
      final publishedCount = updatedArticles.where((a) => !a.isDraft).length;
      final draftsCount = updatedArticles.where((a) => a.isDraft).length;

      emit(UserArticlesActionSuccess(
        successMessage: 'Article deleted successfully',
        articles: updatedArticles,
        filteredArticles: filteredArticles,
        currentFilter: currentState.currentFilter,
      ));

      // Return to loaded state
      emit(UserArticlesLoaded(
        articles: updatedArticles,
        filteredArticles: filteredArticles,
        currentFilter: currentState.currentFilter,
        publishedCount: publishedCount,
        draftsCount: draftsCount,
      ));
    } else {
      emit(UserArticlesError(
        message: dataState.error?.toString() ?? 'Failed to delete article',
      ));
    }
  }

  Future<void> _onPublishArticle(
    PublishArticle event,
    Emitter<UserArticlesState> emit,
  ) async {
    if (state is! UserArticlesLoaded) return;
    final currentState = state as UserArticlesLoaded;

    emit(UserArticlesActionInProgress(
      actionMessage: 'Publishing article...',
      articles: currentState.articles,
      filteredArticles: currentState.filteredArticles,
      currentFilter: currentState.currentFilter,
    ));

    final dataState = await _publishArticleUseCase(params: event.articleId);

    if (dataState is DataSuccess && dataState.data != null) {
      // Update the article in local list
      final updatedArticle = dataState.data!;
      final updatedArticles = currentState.articles!.map((a) {
        return a.id == event.articleId ? updatedArticle : a;
      }).toList();
      final filteredArticles =
          _applyFilter(updatedArticles, currentState.currentFilter);
      final publishedCount = updatedArticles.where((a) => !a.isDraft).length;
      final draftsCount = updatedArticles.where((a) => a.isDraft).length;

      emit(UserArticlesActionSuccess(
        successMessage: 'Article published successfully',
        articles: updatedArticles,
        filteredArticles: filteredArticles,
        currentFilter: currentState.currentFilter,
      ));

      emit(UserArticlesLoaded(
        articles: updatedArticles,
        filteredArticles: filteredArticles,
        currentFilter: currentState.currentFilter,
        publishedCount: publishedCount,
        draftsCount: draftsCount,
      ));
    } else {
      emit(UserArticlesError(
        message: dataState.error?.toString() ?? 'Failed to publish article',
      ));
    }
  }

  Future<void> _onUnpublishArticle(
    UnpublishArticle event,
    Emitter<UserArticlesState> emit,
  ) async {
    if (state is! UserArticlesLoaded) return;
    final currentState = state as UserArticlesLoaded;

    emit(UserArticlesActionInProgress(
      actionMessage: 'Unpublishing article...',
      articles: currentState.articles,
      filteredArticles: currentState.filteredArticles,
      currentFilter: currentState.currentFilter,
    ));

    // For unpublish, we need to call the repository directly or add another use case
    // For now, we'll refresh the articles after the action
    add(const RefreshUserArticles());
  }
}
