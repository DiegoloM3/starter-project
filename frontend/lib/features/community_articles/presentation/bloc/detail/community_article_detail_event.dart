import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article_entity.dart';

sealed class CommunityArticleDetailEvent extends Equatable {
  const CommunityArticleDetailEvent();

  @override
  List<Object?> get props => [];
}

final class CommunityArticleDetailStarted extends CommunityArticleDetailEvent {
  const CommunityArticleDetailStarted({this.article, this.articleId});

  final CommunityArticleEntity? article;
  final String? articleId;

  @override
  List<Object?> get props => [article, articleId];
}

final class CommunityArticleDeleteRequested
    extends CommunityArticleDetailEvent {
  const CommunityArticleDeleteRequested();
}
