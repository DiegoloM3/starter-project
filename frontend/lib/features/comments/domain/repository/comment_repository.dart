import '../../../../core/resources/data_state.dart';
import '../entities/comment.dart';
import '../params/add_comment_params.dart';

abstract class CommentRepository {
  /// Newest first.
  Future<DataState<List<CommentEntity>>> getComments(String articleId);

  /// Comments in the name of the signed in user.
  Future<DataState<CommentEntity>> addComment(AddCommentParams params);

  Future<DataState<void>> deleteComment(CommentEntity comment);
}
