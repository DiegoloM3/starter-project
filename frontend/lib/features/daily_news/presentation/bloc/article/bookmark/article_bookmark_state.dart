import 'package:equatable/equatable.dart';

/// Whether the news article is saved on the phone.
abstract class ArticleBookmarkState extends Equatable {
  final bool isSaved;

  const ArticleBookmarkState(this.isSaved);

  @override
  List<Object?> get props => [isSaved];
}

/// Checking whether it is saved, or saving or removing it.
class ArticleBookmarkInProgress extends ArticleBookmarkState {
  const ArticleBookmarkInProgress(super.isSaved);
}

class ArticleBookmarkSuccess extends ArticleBookmarkState {
  const ArticleBookmarkSuccess(super.isSaved);
}

/// The journalist has just saved or removed the article.
class ArticleBookmarkChanged extends ArticleBookmarkSuccess {
  const ArticleBookmarkChanged(super.isSaved);
}
