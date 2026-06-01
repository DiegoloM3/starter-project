import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_feed_articles_paged_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_saved_article_ids_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/save_article_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/unsave_article_use_case.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final GetFeedArticlesPagedUseCase _getFeedArticlesPaged;
  final GetSavedArticleIdsUseCase _getSavedArticleIds;
  final SaveArticleUseCase _saveArticle;
  final UnsaveArticleUseCase _unsaveArticle;
  final GetAllCategoriesUseCase _getAllCategories;

  String? _userId;
  List<String> _categoryIds = [];
  List<CategoryEntity> _categories = [];
  int _currentPage = 0;
  static const int _pageSize = 10;

  FeedCubit(
    this._getFeedArticlesPaged,
    this._getSavedArticleIds,
    this._saveArticle,
    this._unsaveArticle,
    this._getAllCategories,
  ) : super(const FeedInitial());

  Future<void> loadFeed(String userId) async {
    emit(const FeedLoading());
    _userId = userId;
    _currentPage = 0;

    // Feed shows all published articles — no category filter for now
    _categoryIds = [];

    final articlesResultFuture = _getFeedArticlesPaged(GetFeedArticlesPagedParams(
      categoryIds: _categoryIds,
      page: 0,
      pageSize: _pageSize,
    ));
    final savedResultFuture = _getSavedArticleIds(
      GetSavedArticleIdsParams(userId: userId),
    );
    final categoriesResultFuture = _getAllCategories(const NoParams());

    final articlesResult = await articlesResultFuture;
    final savedResult = await savedResultFuture;
    final categoriesResult = await categoriesResultFuture;

    if (articlesResult.isFailure) {
      emit(FeedError(_mapErrorToMessage(articlesResult.error!)));
      return;
    }

    if (categoriesResult.isSuccess) {
      _categories = categoriesResult.data ?? [];
    }

    final savedIds = savedResult.isSuccess
        ? savedResult.data!.toSet()
        : <String>{};

    emit(FeedLoaded(
      articles: articlesResult.data!,
      currentIndex: 0,
      hasMore: articlesResult.data!.length == _pageSize,
      savedArticleIds: savedIds,
      categories: _categories,
    ));
  }

  void onSwipe() {
    final current = state;
    if (current is! FeedLoaded) return;

    final newIndex = current.currentIndex + 1;

    if (newIndex > current.articles.length) return;

    if (newIndex >= current.articles.length - 2 && current.hasMore) {
      _loadMore();
    }

    emit(FeedLoaded(
      articles: current.articles,
      currentIndex: newIndex,
      hasMore: current.hasMore,
      savedArticleIds: current.savedArticleIds,
      categories: _categories,
    ));
  }

  void shuffleAndRestart() {
    final current = state;
    if (current is! FeedLoaded) return;
    final shuffled = List.of(current.articles)..shuffle();
    emit(FeedLoaded(
      articles: shuffled,
      currentIndex: 0,
      hasMore: current.hasMore,
      savedArticleIds: current.savedArticleIds,
      categories: _categories,
    ));
  }

  Future<void> refresh() async {
    if (_userId == null) return;
    final current = state;
    // Silent refresh — no spinner, keep current articles visible
    _currentPage = 0;
    _categoryIds = [];
    final articlesResult = await _getFeedArticlesPaged(GetFeedArticlesPagedParams(
      categoryIds: _categoryIds,
      page: 0,
      pageSize: _pageSize,
    ));
    if (articlesResult.isFailure) return; // silently ignore on background refresh
    final savedResult = await _getSavedArticleIds(GetSavedArticleIdsParams(userId: _userId!));
    final savedIds = savedResult.isSuccess ? savedResult.data!.toSet() : <String>{};
    final currentIndex = current is FeedLoaded ? current.currentIndex : 0;
    emit(FeedLoaded(
      articles: articlesResult.data!,
      currentIndex: currentIndex.clamp(0, articlesResult.data!.length),
      hasMore: articlesResult.data!.length == _pageSize,
      savedArticleIds: savedIds,
      categories: _categories,
    ));
  }

  Future<void> toggleBookmark(String articleId) async {
    final current = state;
    if (current is! FeedLoaded) return;

    final isSaved = current.savedArticleIds.contains(articleId);
    final optimisticSet = Set<String>.from(current.savedArticleIds);
    if (isSaved) {
      optimisticSet.remove(articleId);
    } else {
      optimisticSet.add(articleId);
    }

    final originalSet = current.savedArticleIds;
    emit(FeedLoaded(
      articles: current.articles,
      currentIndex: current.currentIndex,
      hasMore: current.hasMore,
      savedArticleIds: optimisticSet,
      categories: _categories,
    ));

    if (_userId == null) return;

    final result = isSaved
        ? await _unsaveArticle(
            UnsaveArticleParams(userId: _userId!, articleId: articleId))
        : await _saveArticle(
            SaveArticleParams(userId: _userId!, articleId: articleId));

    if (result.isFailure) {
      final afterOptimistic = state;
      if (afterOptimistic is FeedLoaded) {
        emit(FeedLoaded(
          articles: afterOptimistic.articles,
          currentIndex: afterOptimistic.currentIndex,
          hasMore: afterOptimistic.hasMore,
          savedArticleIds: originalSet,
          categories: _categories,
        ));
      }
    }
  }

  Future<void> _loadMore() async {
    final current = state;
    if (current is! FeedLoaded || !current.hasMore) return;

    emit(FeedLoadingMore(
      articles: current.articles,
      currentIndex: current.currentIndex,
    ));

    _currentPage++;

    final result = await _getFeedArticlesPaged(GetFeedArticlesPagedParams(
      categoryIds: _categoryIds,
      page: _currentPage,
      pageSize: _pageSize,
    ));

    if (result.isSuccess) {
      final newArticles = [...current.articles, ...result.data!];
      emit(FeedLoaded(
        articles: newArticles,
        currentIndex: current.currentIndex,
        hasMore: result.data!.length == _pageSize,
        savedArticleIds: current.savedArticleIds,
        categories: _categories,
      ));
    } else {
      emit(FeedLoaded(
        articles: current.articles,
        currentIndex: current.currentIndex,
        hasMore: false,
        savedArticleIds: current.savedArticleIds,
        categories: _categories,
      ));
    }
  }

  String _mapErrorToMessage(Exception error) {
    return 'Algo salió mal. Inténtalo de nuevo';
  }
}
