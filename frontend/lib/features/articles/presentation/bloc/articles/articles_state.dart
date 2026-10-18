import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';

enum ArticlesStatus { initial, loading, success, failure }

/// Articles of the news tab, split in its two sections. Both are newest first.
class ArticlesState extends Equatable {
  final ArticlesStatus status;

  /// Articles of the authors the user does not follow.
  final List<ArticleEntity> forYouArticles;

  /// Articles of the users the user follows.
  final List<ArticleEntity> followingArticles;

  const ArticlesState({
    this.status = ArticlesStatus.initial,
    this.forYouArticles = const [],
    this.followingArticles = const [],
  });

  ArticlesState withStatus(ArticlesStatus status) {
    return ArticlesState(status: status, forYouArticles: forYouArticles, followingArticles: followingArticles);
  }

  @override
  List<Object?> get props => [status, forYouArticles, followingArticles];
}
