import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../exceptions/article_exceptions.dart';
import '../params/publish_article_params.dart';
import '../repository/article_repository.dart';

/// Validates the article before sending it, so invalid articles never reach the server.
class PublishArticleUseCase implements UseCase<DataState<ArticleEntity>, PublishArticleParams> {
  final ArticleRepository _articleRepository;

  PublishArticleUseCase(this._articleRepository);

  @override
  Future<DataState<ArticleEntity>> call(PublishArticleParams params) async {
    final errors = params.validationErrors;
    if (errors.isNotEmpty) return DataFailed(ArticleValidationException(errors));
    return _articleRepository.publishArticle(params);
  }
}
