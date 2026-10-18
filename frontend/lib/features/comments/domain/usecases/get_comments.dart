import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment.dart';
import '../repository/comment_repository.dart';

class GetCommentsUseCase implements UseCase<DataState<List<CommentEntity>>, String> {
  final CommentRepository _commentRepository;

  GetCommentsUseCase(this._commentRepository);

  @override
  Future<DataState<List<CommentEntity>>> call(String articleId) => _commentRepository.getComments(articleId);
}
