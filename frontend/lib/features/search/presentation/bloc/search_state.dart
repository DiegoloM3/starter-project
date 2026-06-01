import 'package:equatable/equatable.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

abstract class SearchState extends Equatable {
  const SearchState();
}

class SearchInitial extends SearchState {
  final List<String> recentSearches;
  final List<CategoryEntity> categories;

  const SearchInitial({
    required this.recentSearches,
    required this.categories,
  });

  @override
  List<Object?> get props => [recentSearches, categories];
}

class SearchSuggesting extends SearchState {
  final String query;
  final List<String> suggestions;

  const SearchSuggesting({
    required this.query,
    required this.suggestions,
  });

  @override
  List<Object?> get props => [query, suggestions];
}

class SearchLoading extends SearchState {
  final String query;

  const SearchLoading({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchLoaded extends SearchState {
  final String query;
  final List<ArticleEntity> articles;
  final List<CategoryEntity> categories;
  final List<UserEntity> creators;
  final String activeFilter;
  final int activeTab;

  const SearchLoaded({
    required this.query,
    required this.articles,
    required this.categories,
    required this.creators,
    required this.activeFilter,
    required this.activeTab,
  });

  bool get isEmpty =>
      articles.isEmpty && categories.isEmpty && creators.isEmpty;

  List<ArticleEntity> get filteredArticles => activeFilter == 'all'
      ? articles
      : articles.where((a) => a.categoryId == activeFilter).toList();

  SearchLoaded copyWith({
    String? query,
    List<ArticleEntity>? articles,
    List<CategoryEntity>? categories,
    List<UserEntity>? creators,
    String? activeFilter,
    int? activeTab,
  }) {
    return SearchLoaded(
      query: query ?? this.query,
      articles: articles ?? this.articles,
      categories: categories ?? this.categories,
      creators: creators ?? this.creators,
      activeFilter: activeFilter ?? this.activeFilter,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  @override
  List<Object?> get props =>
      [query, articles, categories, creators, activeFilter, activeTab];
}

class SearchEmpty extends SearchState {
  final String query;
  final List<CategoryEntity> suggestedCategories;

  const SearchEmpty({
    required this.query,
    required this.suggestedCategories,
  });

  @override
  List<Object?> get props => [query, suggestedCategories];
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
