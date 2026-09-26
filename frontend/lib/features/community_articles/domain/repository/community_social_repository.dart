import '../../../../core/resources/data_state.dart';
import '../entities/article_comment.dart';

/// Realtime social interactions for a published community article.
abstract class CommunitySocialRepository {
  String? get currentUserId;
  String get currentUserName;

  Stream<Set<String>> watchLikeUserIds(String articleId);

  Stream<List<ArticleCommentEntity>> watchComments(String articleId);

  Future<DataState<void>> setLike(
    String articleId, {
    required bool isLiked,
  });

  Future<DataState<void>> addComment(String articleId, String body);

  Future<DataState<void>> deleteComment(String articleId, String commentId);
}
