import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/exceptions/comment_exceptions.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/params/add_comment_params.dart';

class AddCommentUseCase implements UseCase<CommentEntity, AddCommentParams> {
  final CommentRepository _repository;

  AddCommentUseCase(this._repository);

  @override
  Future<CommentEntity> call({AddCommentParams? params}) {
    if (params == null) {
      throw const InvalidCommentException('Missing comment fields.');
    }
    final trimmed = params.text.trim();
    if (trimmed.isEmpty) {
      throw const InvalidCommentException('Comment cannot be empty.');
    }
    if (trimmed.length > 2000) {
      throw const InvalidCommentException(
          'Comment must be 2000 characters or fewer.');
    }
    if (params.articleId.isEmpty) {
      throw const InvalidCommentException('Article id is required.');
    }
    return _repository.addComment(AddCommentParams(
      articleId: params.articleId,
      text: trimmed,
      replyTo: params.replyTo,
    ));
  }
}
