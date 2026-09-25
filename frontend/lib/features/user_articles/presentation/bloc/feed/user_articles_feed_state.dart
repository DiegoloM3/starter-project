import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

abstract class UserArticlesFeedState extends Equatable {
  const UserArticlesFeedState();

  @override
  List<Object?> get props => [];
}

class UserArticlesFeedLoading extends UserArticlesFeedState {
  const UserArticlesFeedLoading();
}

class UserArticlesFeedLoaded extends UserArticlesFeedState {
  final List<UserArticleEntity> articles;
  final bool hasMore;
  final bool isLoadingMore;

  const UserArticlesFeedLoaded(
    this.articles, {
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  UserArticlesFeedLoaded copyWith({
    List<UserArticleEntity>? articles,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return UserArticlesFeedLoaded(
      articles ?? this.articles,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [articles, hasMore, isLoadingMore];
}

class UserArticlesFeedError extends UserArticlesFeedState {
  final String message;

  const UserArticlesFeedError(this.message);

  @override
  List<Object?> get props => [message];
}
