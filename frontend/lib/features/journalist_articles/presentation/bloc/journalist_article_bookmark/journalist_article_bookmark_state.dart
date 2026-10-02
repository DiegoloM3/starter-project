import 'package:equatable/equatable.dart';

/// Whether the article is in the signed-in journalist's saved articles.
abstract class JournalistArticleBookmarkState extends Equatable {
  final bool isSaved;

  const JournalistArticleBookmarkState(this.isSaved);

  @override
  List<Object?> get props => [isSaved];
}

/// Checking whether it is saved, or saving or removing it.
class JournalistArticleBookmarkInProgress extends JournalistArticleBookmarkState {
  const JournalistArticleBookmarkInProgress(super.isSaved);
}

class JournalistArticleBookmarkSuccess extends JournalistArticleBookmarkState {
  const JournalistArticleBookmarkSuccess(super.isSaved);
}

/// The journalist has just saved or removed the article.
class JournalistArticleBookmarkChanged extends JournalistArticleBookmarkSuccess {
  const JournalistArticleBookmarkChanged(super.isSaved);
}

/// Saving or removing the article failed, so it stays as it was.
class JournalistArticleBookmarkFailure extends JournalistArticleBookmarkState {
  final Exception error;

  const JournalistArticleBookmarkFailure(super.isSaved, this.error);

  @override
  List<Object?> get props => [isSaved, error];
}
