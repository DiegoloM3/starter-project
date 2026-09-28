import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';

/// Contract for article comments stored in Firestore.
abstract interface class CommentRepository {
  Future<DataState<List<CommentEntity>>> getArticleComments(String articleId);

  Future<DataState<void>> postComment(CommentEntity comment);

  Future<DataState<void>> deleteComment(String commentId);
}
