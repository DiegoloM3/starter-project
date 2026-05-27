import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/stream_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/comment_repository.dart';

class GetCommentsUseCase
    implements StreamUseCase<DataState<List<CommentEntity>>, String> {
  final CommentRepository _commentRepository;

  GetCommentsUseCase(this._commentRepository);

  @override
  Stream<DataState<List<CommentEntity>>> call({String? params}) {
    if (params == null) throw ArgumentError('params cannot be null');
    return _commentRepository.getComments(params);
  }
}
