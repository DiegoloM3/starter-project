import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';

/// Input required by [PostComment]: the comment to save.
class PostCommentParams {
  final CommentEntity comment;

  const PostCommentParams({required this.comment});
}

/// Single operation: posts a comment after content validation.
class PostComment implements UseCase<DataState<void>, PostCommentParams> {
  final CommentRepository _commentRepository;

  PostComment(this._commentRepository);

  @override
  Future<DataState<void>> call({PostCommentParams? params}) async {
    if (params == null) return Future.value(DataSuccess(null));
    if (!params.comment.hasUsableContent) {
      return Future.value(
        const DataGenericFailed('Comment cannot be empty.'),
      );
    }
    return await _commentRepository.postComment(params.comment);
  }
}
