import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_feed_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedArticlesUseCase _getFeedArticlesUseCase;
  StreamSubscription<DataState<List<ArticleEntity>>>? _subscription;

  FeedBloc(this._getFeedArticlesUseCase) : super(const FeedLoading()) {
    on<FeedSubscriptionRequested>(_onSubscriptionRequested);
    on<FeedUpdated>(_onUpdated);
  }

  void _onSubscriptionRequested(
    FeedSubscriptionRequested event,
    Emitter<FeedState> emit,
  ) {
    emit(const FeedLoading());
    _subscription?.cancel();
    _subscription = _getFeedArticlesUseCase().listen(
      (dataState) => add(FeedUpdated(dataState)),
      onError: (Object error) {
        add(FeedUpdated(DataFailed(
          AppException(message: error.toString(), code: 'stream_error'),
        )));
      },
    );
  }

  void _onUpdated(
    FeedUpdated event,
    Emitter<FeedState> emit,
  ) {
    if (event.dataState is DataSuccess) {
      emit(FeedDone(event.dataState.data ?? []));
    }
    if (event.dataState is DataFailed) {
      emit(FeedFailure(event.dataState.error!));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
