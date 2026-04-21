import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/params/add_comment_params.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/params/delete_comment_params.dart';

abstract class CommentRepository {
  Future<CommentEntity> addComment(AddCommentParams params);

  Stream<List<CommentEntity>> watchComments(String articleId);

  Future<void> deleteComment(DeleteCommentParams params);
}
