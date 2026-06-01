import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_saved_article_ids_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/save_article_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/unsave_article_use_case.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/explore/domain/use_cases/get_articles_by_category_use_case.dart';
import 'package:tortutip/features/explore/presentation/bloc/category_list_state.dart';

class CategoryListCubit extends Cubit<CategoryListState> {
  final GetArticlesByCategoryUseCase _getArticlesByCategory;
  final GetSavedArticleIdsUseCase _getSavedArticleIds;
  final SaveArticleUseCase _saveArticle;
  final UnsaveArticleUseCase _unsaveArticle;

  int _currentPage = 0;
  static const int _pageSize = 10;

  CategoryListCubit(
    this._getArticlesByCategory,
    this._getSavedArticleIds,
    this._saveArticle,
    this._unsaveArticle,
  ) : super(const CategoryListInitial());

  Future<void> loadCategory(CategoryEntity category, String userId) async {
    _currentPage = 0;
    emit(const CategoryListLoading());

    final results = await Future.wait([
      _getArticlesByCategory(
        GetArticlesByCategoryParams(
            categoryId: category.id, page: 0, pageSize: _pageSize),
      ),
      _getSavedArticleIds(GetSavedArticleIdsParams(userId: userId)),
    ]);

    final articlesResult = results[0] as DataState<List<ArticleEntity>>;
    final savedResult = results[1] as DataState<List<String>>;

    if (articlesResult.isSuccess) {
      final articles = articlesResult.data!;
      if (articles.isEmpty) {
        emit(const CategoryListEmpty());
        return;
      }
      final savedIds =
          savedResult.isSuccess ? savedResult.data!.toSet() : <String>{};
      emit(CategoryListLoaded(
        category: category,
        articles: articles,
        hasMore: articles.length == _pageSize,
        savedArticleIds: savedIds,
      ));
    } else {
      emit(const CategoryListError('No se pudieron cargar los artículos'));
    }
  }

  Future<void> loadMore(String userId) async {
    if (state is! CategoryListLoaded) return;
    final current = state as CategoryListLoaded;
    if (!current.hasMore) return;
    _currentPage++;
    emit(CategoryListLoadingMore(
        category: current.category, articles: current.articles));
    final result = await _getArticlesByCategory(GetArticlesByCategoryParams(
      categoryId: current.category.id,
      page: _currentPage,
      pageSize: _pageSize,
    ));
    if (result.isSuccess) {
      final newArticles = [...current.articles, ...result.data!];
      emit(CategoryListLoaded(
        category: current.category,
        articles: newArticles,
        hasMore: result.data!.length == _pageSize,
        savedArticleIds: current.savedArticleIds,
      ));
    } else {
      _currentPage--;
      emit(current);
    }
  }

  Future<void> toggleBookmark(String articleId, String userId) async {
    if (state is! CategoryListLoaded) return;
    final current = state as CategoryListLoaded;
    final isSaved = current.savedArticleIds.contains(articleId);

    // Optimistic update
    final newSaved = Set<String>.from(current.savedArticleIds);
    if (isSaved) {
      newSaved.remove(articleId);
    } else {
      newSaved.add(articleId);
    }
    emit(CategoryListLoaded(
      category: current.category,
      articles: current.articles,
      hasMore: current.hasMore,
      savedArticleIds: newSaved,
    ));

    final DataState result;
    if (isSaved) {
      result = await _unsaveArticle(
          UnsaveArticleParams(userId: userId, articleId: articleId));
    } else {
      result = await _saveArticle(
          SaveArticleParams(userId: userId, articleId: articleId));
    }

    if (!result.isSuccess) {
      // Revert on failure
      emit(current);
    }
  }
}
