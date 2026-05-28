import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../../domain/entities/article.dart';

abstract class FeedEvent {
  const FeedEvent();
}

class FeedSubscriptionRequested extends FeedEvent {
  const FeedSubscriptionRequested();
}

class FeedUpdated extends FeedEvent {
  final DataState<List<ArticleEntity>> dataState;

  const FeedUpdated(this.dataState);
}
