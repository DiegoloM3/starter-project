import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';

class WatchCommentsUseCase {
  final CommentRepository _repository;

  WatchCommentsUseCase(this._repository);

  Stream<List<CommentEntity>> call(String articleId) =>
      _repository.watchComments(articleId);
}
