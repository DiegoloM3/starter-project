import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';

/// Input required by [DeleteUserArticle]: the article id.
class DeleteUserArticleParams {
  final String articleId;

  const DeleteUserArticleParams({required this.articleId});
}

/// Single operation: deletes a user article by id.
class DeleteUserArticle
    implements UseCase<DataState<void>, DeleteUserArticleParams> {
  final UserArticleRepository _userArticleRepository;

  DeleteUserArticle(this._userArticleRepository);

  @override
  Future<DataState<void>> call({DeleteUserArticleParams? params}) async {
    if (params == null || params.articleId.trim().isEmpty) {
      return Future.value(
        const DataGenericFailed('Cannot delete an article without an id.'),
      );
    }
    return await _userArticleRepository.deleteUserArticle(params.articleId);
  }
}
