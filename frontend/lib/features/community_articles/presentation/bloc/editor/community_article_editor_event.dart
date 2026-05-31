import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article_entity.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/params/community_article_params.dart';

sealed class CommunityArticleEditorEvent extends Equatable {
  const CommunityArticleEditorEvent();

  @override
  List<Object?> get props => [];
}

final class CommunityArticlePublishRequested
    extends CommunityArticleEditorEvent {
  const CommunityArticlePublishRequested(this.params);

  final CreateArticleParams params;

  @override
  List<Object?> get props => [params];
}

final class CommunityArticleUpdateRequested
    extends CommunityArticleEditorEvent {
  const CommunityArticleUpdateRequested(this.params);

  final UpdateArticleParams params;

  @override
  List<Object?> get props => [params];
}

final class CommunityArticleEditorResetRequested
    extends CommunityArticleEditorEvent {
  const CommunityArticleEditorResetRequested();
}

final class CommunityArticleCoverImagePickRequested
    extends CommunityArticleEditorEvent {
  const CommunityArticleCoverImagePickRequested();
}

final class CommunityArticleCoverImageRemoveRequested
    extends CommunityArticleEditorEvent {
  const CommunityArticleCoverImageRemoveRequested({
    required this.hadExistingImage,
  });

  final bool hadExistingImage;

  @override
  List<Object?> get props => [hadExistingImage];
}

final class CommunityArticleEditorLoaded extends CommunityArticleEditorEvent {
  const CommunityArticleEditorLoaded(this.article);

  final CommunityArticleEntity article;

  @override
  List<Object?> get props => [article];
}
