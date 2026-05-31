import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/failure.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article_entity.dart';

sealed class CommunityArticlesEvent extends Equatable {
  const CommunityArticlesEvent();

  @override
  List<Object?> get props => [];
}

final class CommunityArticlesRequested extends CommunityArticlesEvent {
  const CommunityArticlesRequested();
}

final class CommunityArticlesRefreshRequested extends CommunityArticlesEvent {
  const CommunityArticlesRefreshRequested();
}

final class CommunityArticlesNextPageRequested extends CommunityArticlesEvent {
  const CommunityArticlesNextPageRequested();
}

final class CommunityArticlesStreamUpdated extends CommunityArticlesEvent {
  const CommunityArticlesStreamUpdated(this.articles);

  final List<CommunityArticleEntity> articles;

  @override
  List<Object?> get props => [articles];
}

final class CommunityArticlesStreamFailed extends CommunityArticlesEvent {
  const CommunityArticlesStreamFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
