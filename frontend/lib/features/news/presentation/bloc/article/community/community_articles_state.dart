part of 'community_articles_bloc.dart';

/// UI states emitted by [CommunityArticlesBloc].
abstract class CommunityArticlesState extends Equatable {
  const CommunityArticlesState();

  @override
  List<Object?> get props => [];
}

class CommunityArticlesLoading extends CommunityArticlesState {
  const CommunityArticlesLoading();
}

class CommunityArticlesDone extends CommunityArticlesState {
  final List<ArticleEntity> articles;

  const CommunityArticlesDone(this.articles);

  @override
  List<Object?> get props => [articles];
}

class CommunityArticlesError extends CommunityArticlesState {
  final String message;

  const CommunityArticlesError(this.message);

  @override
  List<Object?> get props => [message];
}
