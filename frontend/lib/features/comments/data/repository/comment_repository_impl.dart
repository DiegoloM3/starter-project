import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/comments/data/data_sources/remote/comment_firebase_service.dart';
import 'package:news_app_clean_architecture/features/comments/data/models/comment.model.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';

@LazySingleton(as: CommentRepository)
/// [CommentRepository] implementation over [CommentFirebaseService].
class CommentRepositoryImpl implements CommentRepository {
  static final _log = Logger('CommentRepositoryImpl');

  final CommentFirebaseService _firebaseService;

  CommentRepositoryImpl(this._firebaseService);

  @override
  /// Loads comments for [articleId] and maps models to entities.
  Future<DataState<List<CommentEntity>>> getArticleComments(
    String articleId,
  ) async {
    try {
      final models = await _firebaseService.getArticleComments(articleId);
      return DataSuccess(models.map((model) => model.toEntity()).toList());
    } catch (e, st) {
      _log.severe('getArticleComments → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  /// Persists [comment] to Firestore.
  Future<DataState<void>> postComment(CommentEntity comment) async {
    try {
      await _firebaseService.createComment(
        CommentModel.fromEntity(comment),
      );
      return DataSuccess(null);
    } catch (e, st) {
      _log.severe('postComment → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  @override
  /// Deletes the comment with [commentId].
  Future<DataState<void>> deleteComment(String commentId) async {
    try {
      await _firebaseService.deleteComment(commentId);
      return DataSuccess(null);
    } catch (e, st) {
      _log.severe('deleteComment → failed', e, st);
      return DataGenericFailed(e.toString());
    }
  }
}
