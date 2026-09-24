import 'package:equatable/equatable.dart';

/// Input of `GetPublishedArticlesUseCase`.
///
/// With [authorId] left null this is the general feed of published articles;
/// set, it becomes "more articles from this journalist". [excludeArticleId]
/// leaves out the article a reader may already be looking at.
/// [startAfterArticleId] is the id of the last article of the previous page,
/// so the feed can be paged with a cursor instead of an offset.
class GetPublishedArticlesParams extends Equatable {
  /// How far back the community feed looks.
  ///
  /// The feed answers "what has the community written lately", and without a
  /// window it can only grow: a busy week would bury everything under an
  /// endless scroll, and the oldest article would still be one page away
  /// forever.
  static const Duration feedWindow = Duration(days: 7);

  final int limit;
  final String? authorId;
  final String? excludeArticleId;
  final String? startAfterArticleId;

  /// Only articles published after this moment. Null means no time limit.
  ///
  /// It filters on `publishedAt`, not `updatedAt`, deliberately: an edit does
  /// not make an article new again. Ordering on the edit date is the same
  /// mistake decision #42 fixed, and filtering on it would let an old article
  /// be pulled back into the feed by re-saving it.
  final DateTime? publishedAfter;

  const GetPublishedArticlesParams({
    this.limit = 10,
    this.authorId,
    this.excludeArticleId,
    this.startAfterArticleId,
    this.publishedAfter,
  });

  /// The community feed: only what was published inside [feedWindow].
  ///
  /// [now] is injectable for the same reason `PublishArticleParams` takes its
  /// moment from outside — a rule that reads the clock on its own cannot be
  /// tested.
  GetPublishedArticlesParams.recent({
    this.limit = 10,
    this.authorId,
    this.excludeArticleId,
    this.startAfterArticleId,
    DateTime? now,
  }) : publishedAfter = (now ?? DateTime.now()).subtract(feedWindow);

  @override
  List<Object?> get props => [
        limit,
        authorId,
        excludeArticleId,
        startAfterArticleId,
        publishedAfter,
      ];
}
