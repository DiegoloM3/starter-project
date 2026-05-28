import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/published/published_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/published/published_articles_state.dart';

class PublishedArticlesBloc
    extends Bloc<PublishedArticlesEvent, PublishedArticlesState> {
  final GetPublishedArticlesUseCase _getPublishedArticlesUseCase;
  StreamSubscription<DataState<List<ArticleEntity>>>? _subscription;

  PublishedArticlesBloc(this._getPublishedArticlesUseCase)
      : super(const PublishedArticlesLoading()) {
    on<PublishedArticlesSubscriptionRequested>(
        _onSubscriptionRequested);
    on<PublishedArticlesUpdated>(_onUpdated);
  }

  void _onSubscriptionRequested(
    PublishedArticlesSubscriptionRequested event,
    Emitter<PublishedArticlesState> emit,
  ) {
    emit(const PublishedArticlesLoading());
    _subscription?.cancel();
    _subscription = _getPublishedArticlesUseCase().listen(
      (dataState) => add(PublishedArticlesUpdated(dataState)),
    );
  }

  void _onUpdated(
    PublishedArticlesUpdated event,
    Emitter<PublishedArticlesState> emit,
  ) {
    if (event.dataState is DataSuccess) {
      emit(PublishedArticlesDone(event.dataState.data!));
    }
    if (event.dataState is DataFailed) {
      emit(PublishedArticlesFailure(event.dataState.error!));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
