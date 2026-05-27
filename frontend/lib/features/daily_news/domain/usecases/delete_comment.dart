import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/comment_repository.dart';

class DeleteCommentParams {
  final String articleId;
  final String commentId;

  const DeleteCommentParams({
    required this.articleId,
    required this.commentId,
  });
}

class DeleteCommentUseCase implements UseCase<DataState<void>, DeleteCommentParams> {
  final CommentRepository _commentRepository;

  DeleteCommentUseCase(this._commentRepository);

  @override
  Future<DataState<void>> call({DeleteCommentParams? params}) {
    if (params == null) throw ArgumentError('params cannot be null');
    return _commentRepository.deleteComment(
      articleId: params.articleId,
      commentId: params.commentId,
    );
  }
}
