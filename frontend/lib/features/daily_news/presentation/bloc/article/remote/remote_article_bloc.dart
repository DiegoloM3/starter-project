import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/errors/network_exception.dart';
import 'package:news_app_clean_architecture/core/extensions/list_extensions.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/create_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/page_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_status.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticlesUseCase _getArticleUseCase;
  final CreateArticleUseCase _createArticleUseCase;

  RemoteArticlesBloc(
    this._getArticleUseCase,
    this._createArticleUseCase,
  ) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(_onGetArticles);
    on<CreateArticle>(_onCreateArticle);
    on<NextPage>(_onNextPage);
  }

  Future<void> _onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    emit(const RemoteArticlesLoading());

    final dataState = await _getArticleUseCase(PageParams(page: 0));

    if (dataState is DataSuccess) {
      emit(
        dataState.data?.content.isNullOrEmpty ?? false
            ? const RemoteArticleEmpty()
            : RemoteArticlesDone(
                articles: dataState.data?.content ?? [],
                page: dataState.data?.page ?? 0,
                totalPages: dataState.data?.totalPages ?? 0,
                total: dataState.data?.total,
              ),
      );
    } else {
      emit(RemoteArticlesError(dataState.error! as NetworkException));
    }
  }

  Future<void> _onCreateArticle(
      CreateArticle event, Emitter<RemoteArticlesState> emit) async {
    final dataState = await _createArticleUseCase(
      CreateArticleParams(
        article: event.article,
        file: event.image,
      ),
    );

    if (dataState is DataSuccess) {
      emit(
        RemoteArticlesDone(
          articles: state.articles ?? [],
          status: RemoteArticleStatus.createdArticleSuccess,
        ),
      );
    } else {
      emit(state.articles.isNullOrEmpty
          ? const RemoteArticleEmpty(
              status: RemoteArticleStatus.genericError,
            )
          : RemoteArticlesDone(
              articles: state.articles ?? [],
              status: RemoteArticleStatus.genericError,
            ));
    }

    _clearSnackbar(emit, state);
  }

  void _clearSnackbar(
          Emitter<RemoteArticlesState> emit, RemoteArticlesState state) =>
      emit(
        state is RemoteArticlesDone
            ? RemoteArticlesDone(
                articles: state.articles ?? [],
                status: RemoteArticleStatus.none,
              )
            : const RemoteArticleEmpty(
                status: RemoteArticleStatus.none,
              ),
      );

  Future<void> _onNextPage(
      NextPage event, Emitter<RemoteArticlesState> emit) async {
    if (state is RemoteArticlesDone) {
      final currentState = state as RemoteArticlesDone;

      if (!currentState.isLast) {
        emit(
          currentState.copyWith(
            page: currentState.page + 1,
          ),
        );
        final dataState = await _getArticleUseCase(
          PageParams(page: currentState.page + 1),
        );

        if (dataState is DataSuccess) {
          emit(RemoteArticlesDone(
            articles: [
              ...state.articles ?? [],
              ...dataState.data?.content ?? [],
            ],
            page: dataState.data?.page ?? currentState.page + 1,
            totalPages: dataState.data?.totalPages ?? currentState.totalPages,
            total: dataState.data?.total ?? currentState.total,
          ));
        }
      }
    }
  }
}
