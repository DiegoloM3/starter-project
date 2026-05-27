import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';

abstract class CommentRepository {
  Future<DataState<CommentEntity>> addComment(CommentEntity comment);

  Stream<DataState<List<CommentEntity>>> getComments(String articleId);

  Future<DataState<void>> deleteComment({
    required String articleId,
    required String commentId,
  });
}
