import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/failure.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article_entity.dart';

enum CommunityArticlesStatus { initial, loading, success, failure }

class CommunityArticlesState extends Equatable {
  const CommunityArticlesState({
    this.status = CommunityArticlesStatus.initial,
    this.articles = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.failure,
  });

  final CommunityArticlesStatus status;
  final List<CommunityArticleEntity> articles;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;

  CommunityArticlesState copyWith({
    CommunityArticlesStatus? status,
    List<CommunityArticleEntity>? articles,
    bool? hasMore,
    bool? isLoadingMore,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CommunityArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    articles,
    hasMore,
    isLoadingMore,
    failure,
  ];
}
