import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';

/// Every state keeps the [draft], so what the journalist wrote is not lost if sending fails.
abstract class AddArticleCommentState extends Equatable {
  final ArticleCommentDraftEntity draft;

  const AddArticleCommentState(this.draft);

  @override
  List<Object?> get props => [draft];
}

class AddArticleCommentEditing extends AddArticleCommentState {
  const AddArticleCommentEditing(super.draft);
}

class AddArticleCommentInProgress extends AddArticleCommentState {
  const AddArticleCommentInProgress(super.draft);
}

/// The [comment] was added, and the [draft] is empty again for the next one.
class AddArticleCommentSuccess extends AddArticleCommentState {
  final ArticleCommentEntity comment;

  const AddArticleCommentSuccess(super.draft, this.comment);

  @override
  List<Object?> get props => [draft, comment];
}

class AddArticleCommentFailure extends AddArticleCommentState {
  final Exception error;

  const AddArticleCommentFailure(super.draft, this.error);

  @override
  List<Object?> get props => [draft, error];
}
