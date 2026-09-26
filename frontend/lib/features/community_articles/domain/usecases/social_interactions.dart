import '../../../../core/resources/data_state.dart';
import '../entities/article_comment.dart';
import '../repository/community_social_repository.dart';

class WatchArticleLikesUseCase {
  final CommunitySocialRepository _repository;

  const WatchArticleLikesUseCase(this._repository);

  Stream<Set<String>> call(String articleId) =>
      _repository.watchLikeUserIds(articleId);
}

class WatchArticleCommentsUseCase {
  final CommunitySocialRepository _repository;

  const WatchArticleCommentsUseCase(this._repository);

  Stream<List<ArticleCommentEntity>> call(String articleId) =>
      _repository.watchComments(articleId);
}

class ToggleArticleLikeUseCase {
  final CommunitySocialRepository _repository;

  const ToggleArticleLikeUseCase(this._repository);

  Future<DataState<void>> call(
    String articleId, {
    required bool isLiked,
  }) =>
      _repository.setLike(articleId, isLiked: isLiked);
}

class AddArticleCommentUseCase {
  final CommunitySocialRepository _repository;

  const AddArticleCommentUseCase(this._repository);

  Future<DataState<void>> call(String articleId, String body) =>
      _repository.addComment(articleId, body);
}

class DeleteArticleCommentUseCase {
  final CommunitySocialRepository _repository;

  const DeleteArticleCommentUseCase(this._repository);

  Future<DataState<void>> call(String articleId, String commentId) =>
      _repository.deleteComment(articleId, commentId);
}
