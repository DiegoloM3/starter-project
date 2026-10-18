import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment.dart';
import '../repository/comment_repository.dart';

/// Comments cannot be edited: their authors delete them and write a new one.
class DeleteCommentUseCase implements UseCase<DataState<void>, CommentEntity> {
  final CommentRepository _commentRepository;

  DeleteCommentUseCase(this._commentRepository);

  @override
  Future<DataState<void>> call(CommentEntity comment) => _commentRepository.deleteComment(comment);
}
