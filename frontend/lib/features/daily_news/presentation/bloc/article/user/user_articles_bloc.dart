import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/user/user_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/user/user_articles_state.dart';

class UserArticlesBloc extends Bloc<UserArticlesEvent, UserArticlesState> {
  final GetUserArticlesUseCase _getUserArticlesUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  StreamSubscription<DataState<List<ArticleEntity>>>? _subscription;
  List<ArticleEntity> _allArticles = [];

  UserArticlesBloc(
    this._getUserArticlesUseCase,
    this._deleteArticleUseCase,
  ) : super(const UserArticlesLoading()) {
    on<UserArticlesSubscriptionRequested>(_onSubscriptionRequested);
    on<UserArticlesUpdated>(_onUpdated);
    on<UserArticlesFilterChanged>(_onFilterChanged);
    on<UserArticleDeleteRequested>(_onDeleteRequested);
  }

  void _onSubscriptionRequested(
    UserArticlesSubscriptionRequested event,
    Emitter<UserArticlesState> emit,
  ) {
    emit(UserArticlesLoading(filter: state.filter));
    _subscription?.cancel();
    _subscription = _getUserArticlesUseCase(params: event.userId).listen(
      (dataState) => add(UserArticlesUpdated(dataState)),
      onError: (Object error) {
        add(UserArticlesUpdated(DataFailed(
          AppException(message: error.toString(), code: 'stream_error'),
        )));
      },
    );
  }

  void _onUpdated(
    UserArticlesUpdated event,
    Emitter<UserArticlesState> emit,
  ) {
    if (event.dataState is DataSuccess) {
      _allArticles = event.dataState.data ?? [];
      emit(UserArticlesDone(
        _applyFilter(_allArticles, state.filter),
        filter: state.filter,
      ));
    }
    if (event.dataState is DataFailed) {
      emit(UserArticlesFailure(event.dataState.error!, filter: state.filter));
    }
  }

  void _onFilterChanged(
    UserArticlesFilterChanged event,
    Emitter<UserArticlesState> emit,
  ) {
    emit(UserArticlesDone(
      _applyFilter(_allArticles, event.filter),
      filter: event.filter,
    ));
  }

  Future<void> _onDeleteRequested(
    UserArticleDeleteRequested event,
    Emitter<UserArticlesState> emit,
  ) async {
    final result = await _deleteArticleUseCase(params: event.articleId);
    if (result is DataFailed) {
      emit(UserArticlesFailure(result.error!, filter: state.filter));
    }
  }

  List<ArticleEntity> _applyFilter(
    List<ArticleEntity> articles,
    String filter,
  ) {
    if (filter == UserArticlesFilter.all) return articles;
    if (filter == UserArticlesFilter.drafts) {
      return articles
          .where((a) => a.status == ArticleStatus.draft)
          .toList();
    }
    if (filter == UserArticlesFilter.published) {
      return articles
          .where((a) => a.status == ArticleStatus.published)
          .toList();
    }
    if (filter == UserArticlesFilter.archived) {
      return articles
          .where((a) => a.status == ArticleStatus.archived)
          .toList();
    }
    return articles;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
