import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment.dart';
import '../exceptions/comment_exceptions.dart';
import '../params/add_comment_params.dart';
import '../repository/comment_repository.dart';

class AddCommentUseCase implements UseCase<DataState<CommentEntity>, AddCommentParams> {
  final CommentRepository _commentRepository;

  AddCommentUseCase(this._commentRepository);

  @override
  Future<DataState<CommentEntity>> call(AddCommentParams params) async {
    final errors = params.validationErrors;
    if (errors.isNotEmpty) return DataFailed(CommentValidationException(errors));
    return _commentRepository.addComment(params);
  }
}
