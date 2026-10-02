import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_comment_repository.dart';

/// [call] receives the ID of the article whose comments are read.
class GetArticleCommentsUseCase implements UseCase<DataState<List<ArticleCommentEntity>>, String> {
  final ArticleCommentRepository _articleCommentRepository;

  GetArticleCommentsUseCase(this._articleCommentRepository);

  @override
  Future<DataState<List<ArticleCommentEntity>>> call({String? params}) {
    return _articleCommentRepository.getComments(params!);
  }
}
