import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_user_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/use_cases/delete_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/use_cases/get_user_articles_usecase.dart';

part 'user_articles_event.dart';
part 'user_articles_state.dart';

class UserArticlesBloc extends Bloc<UserArticlesEvent, UserArticlesState> {
  final GetUserArticlesUseCase _getMyArticlesUseCase;
  final DeleteUserArticleUseCase _deleteArticleUseCase;

  UserArticlesBloc({
    required GetUserArticlesUseCase getMyArticlesUseCase,
    required DeleteUserArticleUseCase deleteArticleUseCase,
  })  : _getMyArticlesUseCase = getMyArticlesUseCase,
        _deleteArticleUseCase = deleteArticleUseCase,
        super(UserArticlesLoading()) {
    on<GetUserArticles>(_onGetUserArticles);
    on<DeleteUserArticle>(_onDeleteUserArticle);
  }

  Future<void> _onGetUserArticles(
      GetUserArticles event, Emitter<UserArticlesState> emit) async {
    emit(const UserArticlesLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    final result = await _getMyArticlesUseCase.call();
    switch (result) {
      case DataSuccess(data: final articles):
        emit(UserArticlesDone(articles: articles!));
      case DataFailed(error: final error):
        emit(
            UserArticlesError(message: error!.toString(), showSnackbar: false));
    }
  }

    Future<void> _onDeleteUserArticle(DeleteUserArticle event, Emitter<UserArticlesState> emit) async {
      final currentState = state;
      if (currentState is! UserArticlesDone) return;

      final optimisticList = currentState.articles.where((a) => a.id != event.article.id).toList();
      emit(UserArticlesDone(articles: optimisticList)); 

      final result = await _deleteArticleUseCase.call(
        params: DeleteUserArticleParams(id: event.article.id!, thumbnailUrl: event.article.thumbnailUrl),
      );

      switch (result) {
        case DataSuccess():
          break;  
        case DataFailed(error: final error):
          emit(UserArticlesDone(articles: currentState.articles));
          emit(UserArticlesError(message: error!.toString(), showSnackbar: true));
      }
    }
}
