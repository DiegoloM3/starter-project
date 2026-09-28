import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';

/// Input required by [GetArticleComments]: the article id.
class GetArticleCommentsParams {
  final String articleId;

  const GetArticleCommentsParams({required this.articleId});
}

/// Single operation: returns comments for one article id.
class GetArticleComments
    implements UseCase<DataState<List<CommentEntity>>, GetArticleCommentsParams> {
  final CommentRepository _commentRepository;

  GetArticleComments(this._commentRepository);

  @override
  Future<DataState<List<CommentEntity>>> call({
    GetArticleCommentsParams? params,
  }) async {
    if (params == null) return Future.value(DataSuccess(const []));
    return await _commentRepository.getArticleComments(params.articleId);
  }
}
