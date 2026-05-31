import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/failure.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article_entity.dart';

enum CommunityArticleDetailStatus {
  initial,
  loading,
  success,
  deleting,
  deleted,
  failure,
}

class CommunityArticleDetailState extends Equatable {
  const CommunityArticleDetailState({
    this.status = CommunityArticleDetailStatus.initial,
    this.article,
    this.failure,
  });

  final CommunityArticleDetailStatus status;
  final CommunityArticleEntity? article;
  final Failure? failure;

  CommunityArticleDetailState copyWith({
    CommunityArticleDetailStatus? status,
    CommunityArticleEntity? article,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CommunityArticleDetailState(
      status: status ?? this.status,
      article: article ?? this.article,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, article, failure];
}
