import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../../domain/entities/article.dart';

abstract class PublishedArticlesEvent {
  const PublishedArticlesEvent();
}

class PublishedArticlesSubscriptionRequested
    extends PublishedArticlesEvent {
  const PublishedArticlesSubscriptionRequested();
}

class PublishedArticlesUpdated extends PublishedArticlesEvent {
  final DataState<List<ArticleEntity>> dataState;

  const PublishedArticlesUpdated(this.dataState);
}
