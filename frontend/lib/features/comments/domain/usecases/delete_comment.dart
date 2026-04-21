import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/comments/domain/exceptions/comment_exceptions.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/params/delete_comment_params.dart';

class DeleteCommentUseCase implements UseCase<void, DeleteCommentParams> {
  final CommentRepository _repository;

  DeleteCommentUseCase(this._repository);

  @override
  Future<void> call({DeleteCommentParams? params}) {
    if (params == null ||
        params.articleId.isEmpty ||
        params.commentId.isEmpty) {
      throw const InvalidCommentException(
          'Article and comment ids are required.');
    }
    return _repository.deleteComment(params);
  }
}
