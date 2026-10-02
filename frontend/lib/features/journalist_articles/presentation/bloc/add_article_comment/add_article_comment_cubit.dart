import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/add_article_comment.dart';

import 'add_article_comment_state.dart';

/// Comment that the journalist is writing on the article with the given ID.
class AddArticleCommentCubit extends Cubit<AddArticleCommentState> {
  final AddArticleCommentUseCase _addArticleCommentUseCase;

  AddArticleCommentCubit(this._addArticleCommentUseCase, String articleId)
      : super(AddArticleCommentEditing(ArticleCommentDraftEntity(articleId: articleId)));

  void updateContent(String content) => emit(AddArticleCommentEditing(state.draft.copyWith(content: content)));

  Future<void> send() async {
    if (state is AddArticleCommentInProgress) return;
    final draft = state.draft;
    emit(AddArticleCommentInProgress(draft));
    final dataState = await _addArticleCommentUseCase(params: draft);
    if (dataState is DataSuccess) {
      emit(AddArticleCommentSuccess(draft.copyWith(content: ''), dataState.data!));
      return;
    }
    _emitSendFailure(draft, dataState.error!);
  }

  /// An empty comment is simply not sent: the send button is disabled until there is something to send.
  void _emitSendFailure(ArticleCommentDraftEntity draft, Exception error) {
    if (error is InvalidArticleCommentDraftException) {
      emit(AddArticleCommentEditing(draft));
      return;
    }
    emit(AddArticleCommentFailure(draft, error));
  }
}
