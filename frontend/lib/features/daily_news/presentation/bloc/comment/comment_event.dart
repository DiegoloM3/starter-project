import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../domain/entities/comment.dart';

abstract class CommentEvent {
  const CommentEvent();
}

class CommentsSubscriptionRequested extends CommentEvent {
  final String articleId;

  const CommentsSubscriptionRequested(this.articleId);
}

class CommentsUpdated extends CommentEvent {
  final DataState<List<CommentEntity>> dataState;

  const CommentsUpdated(this.dataState);
}

class CommentAdded extends CommentEvent {
  final CommentEntity comment;

  const CommentAdded(this.comment);
}

class CommentDeleted extends CommentEvent {
  final String articleId;
  final String commentId;

  const CommentDeleted({
    required this.articleId,
    required this.commentId,
  });
}
