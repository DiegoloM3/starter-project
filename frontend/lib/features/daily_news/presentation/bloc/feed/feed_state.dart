part of 'feed_cubit.dart';

sealed class FeedState extends Equatable {
  /// The query the state refers to; `null` before the first load.
  final NewsQuery? query;

  const FeedState(this.query);

  @override
  List<Object?> get props => [query];
}

final class FeedInitial extends FeedState {
  const FeedInitial() : super(null);
}

final class FeedLoading extends FeedState {
  const FeedLoading(super.query);
}

final class FeedLoaded extends FeedState {
  final FeedEntity feed;
  final DateTime loadedAt;

  const FeedLoaded(super.query, this.feed, {required this.loadedAt});

  bool get isEmpty => feed.isEmpty && feed.remoteFailure == null;

  @override
  List<Object?> get props => [query, feed, loadedAt];
}

/// Neither source answered.
final class FeedFailure extends FeedState {
  final Failure failure;

  const FeedFailure(super.query, this.failure);

  @override
  List<Object?> get props => [query, failure];
}
