import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article_comment.dart';
import '../../domain/repository/community_social_repository.dart';
import '../data_sources/community_social_firestore_data_source.dart';

class CommunitySocialRepositoryImpl implements CommunitySocialRepository {
  final CommunitySocialFirestoreDataSource _firestore;

  const CommunitySocialRepositoryImpl(this._firestore);

  @override
  String? get currentUserId => _firestore.currentUserId;

  @override
  String get currentUserName => _firestore.currentUserName;

  @override
  Stream<Set<String>> watchLikeUserIds(String articleId) =>
      _firestore.watchLikeUserIds(articleId);

  @override
  Stream<List<ArticleCommentEntity>> watchComments(String articleId) =>
      _firestore.watchComments(articleId);

  @override
  Future<DataState<void>> setLike(
    String articleId, {
    required bool isLiked,
  }) async {
    try {
      await _firestore.setLike(articleId, isLiked: isLiked);
      return const DataSuccess(null);
    } catch (error) {
      return DataFailed(
          AppFailure(_messageFor(error, action: 'like'), cause: error));
    }
  }

  @override
  Future<DataState<void>> addComment(String articleId, String body) async {
    try {
      await _firestore.addComment(articleId, body);
      return const DataSuccess(null);
    } catch (error) {
      return DataFailed(
        AppFailure(_messageFor(error, action: 'comment'), cause: error),
      );
    }
  }

  @override
  Future<DataState<void>> deleteComment(
    String articleId,
    String commentId,
  ) async {
    try {
      await _firestore.deleteComment(articleId, commentId);
      return const DataSuccess(null);
    } catch (error) {
      return DataFailed(
        AppFailure(_messageFor(error, action: 'delete comment'), cause: error),
      );
    }
  }

  String _messageFor(Object error, {required String action}) {
    final message = error.toString();
    if (message.contains('Sign in')) return 'Sign in to $action.';
    if (error is FormatException) return error.message.toString();
    return 'Unable to $action right now. Please try again.';
  }
}
