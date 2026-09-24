import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_failures.dart';
import '../entities/journalist_article.dart';
import '../params/update_article_params.dart';
import '../repository/journalist_article_repository.dart';

/// Saves the edits a journalist made to one of their stored articles.
///
/// The article keeps its current status, so editing a published article is
/// validated with the stricter publishing rules.
class UpdateArticleUseCase
    implements
        UseCase<DataState<JournalistArticleEntity>, UpdateArticleParams> {
  final JournalistArticleRepository _articleRepository;

  const UpdateArticleUseCase(this._articleRepository);

  @override
  Future<DataState<JournalistArticleEntity>> call(
    UpdateArticleParams params,
  ) async {
    final article = params.article;

    if (!article.isStored) {
      return const DataFailed(ArticleNotStoredException());
    }

    final validationErrors = article.validate();

    if (validationErrors.isNotEmpty) {
      return DataFailed(ArticleValidationException(validationErrors));
    }

    return _articleRepository.updateArticle(article);
  }
}
