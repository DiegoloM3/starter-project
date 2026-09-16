import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_feed.dart';

part 'feed_state.dart';

/// Loads the Home timeline for the current query and reloads it on demand.
///
/// A partial feed (provider down, own articles fine) is still a
/// [FeedLoaded]; the screen reads `feed.remoteFailure` to show the error
/// card above the articles that did arrive.
class FeedCubit extends Cubit<FeedState> {
  final GetFeedUseCase _getFeed;
  int _requestCount = 0;

  FeedCubit(this._getFeed) : super(const FeedInitial());

  Future<void> load(NewsQuery query) async {
    final request = ++_requestCount;
    emit(FeedLoading(query));

    final result = await _getFeed(query);
    if (isClosed || request != _requestCount) return;

    emit(switch (result) {
      DataSuccess(:final data) => FeedLoaded(query, data, loadedAt: DateTime.now()),
      DataFailed(:final failure) => FeedFailure(query, failure),
    });
  }

  /// Pull-to-refresh: keeps the current articles on screen while reloading.
  /// Counted like [load], so a refresh that lands after a newer load is
  /// dropped instead of painting the old category over the new one.
  Future<void> refresh() async {
    final query = state.query;
    if (query == null) return;
    final request = ++_requestCount;

    final result = await _getFeed(query);
    if (isClosed || request != _requestCount) return;

    emit(switch (result) {
      DataSuccess(:final data) => FeedLoaded(query, data, loadedAt: DateTime.now()),
      DataFailed(:final failure) => FeedFailure(query, failure),
    });
  }
}
