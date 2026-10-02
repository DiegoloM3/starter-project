import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';

abstract class ArticleCommentRepository {
  /// Comments of the article [articleId], oldest first, like a conversation.
  Future<DataState<List<ArticleCommentEntity>>> getComments(String articleId);

  /// Adds the comment in the name of the signed-in journalist and returns it as stored.
  Future<DataState<ArticleCommentEntity>> addComment(ArticleCommentDraftEntity draft);
}
