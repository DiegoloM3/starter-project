import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../params/delete_article_params.dart';
import '../repository/journalist_article_repository.dart';

/// Removes one of the journalist's articles permanently.
class DeleteArticleUseCase
    implements UseCase<DataState<void>, DeleteArticleParams> {
  final JournalistArticleRepository _articleRepository;

  const DeleteArticleUseCase(this._articleRepository);

  @override
  Future<DataState<void>> call(DeleteArticleParams params) {
    return _articleRepository.deleteArticle(params.articleId);
  }
}
