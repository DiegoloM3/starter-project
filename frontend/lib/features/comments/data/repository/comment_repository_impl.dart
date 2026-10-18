import '../../../../core/resources/data_state.dart';
import '../../domain/entities/comment.dart';
import '../../domain/params/add_comment_params.dart';
import '../../domain/repository/comment_repository.dart';
import '../data_sources/remote/comment_remote_data_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource _dataSource;

  CommentRepositoryImpl(this._dataSource);

  @override
  Future<DataState<List<CommentEntity>>> getComments(String articleId) {
    return runAsDataState(() async {
      final comments = await _dataSource.getComments(articleId);
      return comments.map((comment) => comment.toEntity()).toList();
    });
  }

  @override
  Future<DataState<CommentEntity>> addComment(AddCommentParams params) {
    return runAsDataState(() async => (await _dataSource.addComment(params.articleId, params.text)).toEntity());
  }

  @override
  Future<DataState<void>> deleteComment(CommentEntity comment) {
    return runAsDataState(() => _dataSource.deleteComment(comment.articleId, comment.id));
  }
}
