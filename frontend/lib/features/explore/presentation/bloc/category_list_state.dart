import 'package:equatable/equatable.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';

abstract class CategoryListState extends Equatable {
  const CategoryListState();

  @override
  List<Object> get props => [];
}

class CategoryListInitial extends CategoryListState {
  const CategoryListInitial();
}

class CategoryListLoading extends CategoryListState {
  const CategoryListLoading();
}

class CategoryListLoaded extends CategoryListState {
  final CategoryEntity category;
  final List<ArticleEntity> articles;
  final bool hasMore;
  final Set<String> savedArticleIds;

  const CategoryListLoaded({
    required this.category,
    required this.articles,
    required this.hasMore,
    required this.savedArticleIds,
  });

  @override
  List<Object> get props => [category, articles, hasMore, savedArticleIds];
}

class CategoryListLoadingMore extends CategoryListState {
  final CategoryEntity category;
  final List<ArticleEntity> articles;

  const CategoryListLoadingMore({
    required this.category,
    required this.articles,
  });

  @override
  List<Object> get props => [category, articles];
}

class CategoryListEmpty extends CategoryListState {
  const CategoryListEmpty();
}

class CategoryListError extends CategoryListState {
  final String message;

  const CategoryListError(this.message);

  @override
  List<Object> get props => [message];
}
