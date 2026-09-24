import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_failures.dart';
import '../entities/journalist_article.dart';
import '../params/publish_article_params.dart';
import '../repository/journalist_article_repository.dart';

/// Makes a stored draft readable by the whole audience.
///
/// Publishing is a business operation of its own and not a plain update: an
/// incomplete draft is perfectly valid while it stays private, but it must be
/// complete before it reaches the readers.
class PublishArticleUseCase
    implements
        UseCase<DataState<JournalistArticleEntity>, PublishArticleParams> {
  final JournalistArticleRepository _articleRepository;

  const PublishArticleUseCase(this._articleRepository);

  @override
  Future<DataState<JournalistArticleEntity>> call(
    PublishArticleParams params,
  ) async {
    final article = params.article;

    if (!article.isStored) {
      return const DataFailed(ArticleNotStoredException());
    }

    final validationErrors = article.validateForPublishing();

    if (validationErrors.isNotEmpty) {
      return DataFailed(ArticleValidationException(validationErrors));
    }

    return _articleRepository.updateArticle(
      article.markAsPublished(params.publishedAt),
    );
  }
}
