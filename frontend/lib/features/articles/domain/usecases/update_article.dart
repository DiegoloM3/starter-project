import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../exceptions/article_exceptions.dart';
import '../params/update_article_params.dart';
import '../repository/article_repository.dart';

/// Validates the changes before sending them, so invalid articles never reach the server.
class UpdateArticleUseCase implements UseCase<DataState<ArticleEntity>, UpdateArticleParams> {
  final ArticleRepository _articleRepository;

  UpdateArticleUseCase(this._articleRepository);

  @override
  Future<DataState<ArticleEntity>> call(UpdateArticleParams params) async {
    final errors = params.validationErrors;
    if (errors.isNotEmpty) return DataFailed(ArticleValidationException(errors));
    return _articleRepository.updateArticle(params);
  }
}
