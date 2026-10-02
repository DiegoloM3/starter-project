import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/article_comment_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_comment_repository.dart';

class ArticleCommentRepositoryImpl implements ArticleCommentRepository {
  final ArticleCommentRemoteDataSource _commentDataSource;

  ArticleCommentRepositoryImpl(this._commentDataSource);

  @override
  Future<DataState<List<ArticleCommentEntity>>> getComments(String articleId) async {
    try {
      final comments = await _commentDataSource.getComments(articleId);
      return DataSuccess(comments.map((comment) => comment.toEntity()).toList());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<ArticleCommentEntity>> addComment(ArticleCommentDraftEntity draft) async {
    try {
      final rawData = ArticleCommentModel.buildRawDataOfNewComment(draft);
      final comment = await _commentDataSource.addComment(draft.articleId, rawData);
      return DataSuccess(comment.toEntity());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }
}
