import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../../domain/entities/article.dart';

abstract class UserArticlesEvent {
  const UserArticlesEvent();
}

class UserArticlesSubscriptionRequested extends UserArticlesEvent {
  final String userId;

  const UserArticlesSubscriptionRequested(this.userId);
}

class UserArticlesUpdated extends UserArticlesEvent {
  final DataState<List<ArticleEntity>> dataState;

  const UserArticlesUpdated(this.dataState);
}

class UserArticlesFilterChanged extends UserArticlesEvent {
  final String filter;

  const UserArticlesFilterChanged(this.filter);
}

class UserArticleDeleteRequested extends UserArticlesEvent {
  final String articleId;

  const UserArticleDeleteRequested(this.articleId);
}
