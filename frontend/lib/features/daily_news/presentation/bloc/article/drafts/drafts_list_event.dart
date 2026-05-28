abstract class DraftsListEvent {
  const DraftsListEvent();
}

class DraftsSubscriptionRequested extends DraftsListEvent {
  final String userId;

  const DraftsSubscriptionRequested(this.userId);
}

class DraftDeleted extends DraftsListEvent {
  final String articleId;

  const DraftDeleted(this.articleId);
}
