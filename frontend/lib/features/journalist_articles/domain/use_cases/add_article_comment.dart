import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_comment_repository.dart';

class AddArticleCommentUseCase implements UseCase<DataState<ArticleCommentEntity>, ArticleCommentDraftEntity> {
  final ArticleCommentRepository _articleCommentRepository;

  AddArticleCommentUseCase(this._articleCommentRepository);

  @override
  Future<DataState<ArticleCommentEntity>> call({ArticleCommentDraftEntity? params}) async {
    final draft = params!;
    if (!draft.isValid) return DataFailed(InvalidArticleCommentDraftException(draft));
    return _articleCommentRepository.addComment(draft);
  }
}
