import 'package:equatable/equatable.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedLoaded extends FeedState {
  final List<ArticleEntity> articles;
  final int currentIndex;
  final bool hasMore;
  final Set<String> savedArticleIds;
  final List<CategoryEntity> categories;

  const FeedLoaded({
    required this.articles,
    required this.currentIndex,
    required this.hasMore,
    required this.savedArticleIds,
    this.categories = const [],
  });

  String categoryName(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId).name;
    } catch (_) {
      return categoryId;
    }
  }

  @override
  List<Object?> get props => [articles, currentIndex, hasMore, savedArticleIds.toList(), categories];
}

class FeedLoadingMore extends FeedState {
  final List<ArticleEntity> articles;
  final int currentIndex;

  const FeedLoadingMore({required this.articles, required this.currentIndex});

  @override
  List<Object?> get props => [articles, currentIndex];
}

class FeedError extends FeedState {
  final String message;
  const FeedError(this.message);

  @override
  List<Object?> get props => [message];
}
