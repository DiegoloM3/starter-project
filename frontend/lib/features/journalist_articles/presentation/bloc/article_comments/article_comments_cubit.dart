import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_article_comments.dart';

import 'article_comments_state.dart';

/// Comments of the article with ID [_articleId].
class ArticleCommentsCubit extends Cubit<ArticleCommentsState> {
  final GetArticleCommentsUseCase _getArticleCommentsUseCase;
  final String _articleId;

  ArticleCommentsCubit(this._getArticleCommentsUseCase, this._articleId) : super(const ArticleCommentsInProgress());

  /// When refreshing, the comments already shown stay on screen until the new ones arrive.
  Future<void> loadComments() async {
    if (state is! ArticleCommentsSuccess) emit(const ArticleCommentsInProgress());
    final dataState = await _getArticleCommentsUseCase(params: _articleId);
    if (dataState is DataSuccess) {
      emit(ArticleCommentsSuccess(dataState.data!));
      return;
    }
    emit(ArticleCommentsFailure(dataState.error!));
  }

  /// Shows the comment the journalist has just added at the end of the conversation.
  void showAddedComment(ArticleCommentEntity comment) {
    final state = this.state;
    if (state is ArticleCommentsSuccess) {
      emit(ArticleCommentsSuccess([...state.comments, comment]));
      return;
    }
    loadComments();
  }
}
