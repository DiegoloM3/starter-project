import 'package:news_app_clean_architecture/features/comments/data/data_sources/firestore_comment_data_source.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/params/add_comment_params.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/params/delete_comment_params.dart';

class CommentRepositoryImpl implements CommentRepository {
  final FirestoreCommentDataSource _dataSource;

  CommentRepositoryImpl(this._dataSource);

  @override
  Future<CommentEntity> addComment(AddCommentParams params) async {
    final model = await _dataSource.create(params);
    return model.toEntity();
  }

  @override
  Stream<List<CommentEntity>> watchComments(String articleId) {
    return _dataSource
        .watch(articleId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> deleteComment(DeleteCommentParams params) =>
      _dataSource.markDeleted(params);
}
