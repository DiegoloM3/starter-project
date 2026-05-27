import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/comment_repository.dart';

class AddCommentUseCase implements UseCase<DataState<CommentEntity>, CommentEntity> {
  final CommentRepository _commentRepository;

  AddCommentUseCase(this._commentRepository);

  @override
  Future<DataState<CommentEntity>> call({CommentEntity? params}) {
    if (params == null) throw ArgumentError('params cannot be null');
    return _commentRepository.addComment(params);
  }
}
