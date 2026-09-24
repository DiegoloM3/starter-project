import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_failures.dart';
import '../entities/journalist_article.dart';
import '../params/create_article_params.dart';
import '../repository/journalist_article_repository.dart';

/// Stores a brand new article written by a journalist.
///
/// A draft only needs a title and its author, while an article created as
/// published must already be complete: the rules live in the entity and are
/// applied here before reaching the repository.
class CreateArticleUseCase
    implements
        UseCase<DataState<JournalistArticleEntity>, CreateArticleParams> {
  final JournalistArticleRepository _articleRepository;

  const CreateArticleUseCase(this._articleRepository);

  @override
  Future<DataState<JournalistArticleEntity>> call(
    CreateArticleParams params,
  ) async {
    final article = _articleFrom(params);
    final validationErrors = article.validate();

    if (validationErrors.isNotEmpty) {
      return DataFailed(ArticleValidationException(validationErrors));
    }

    return _articleRepository.createArticle(article);
  }

  JournalistArticleEntity _articleFrom(CreateArticleParams params) {
    return JournalistArticleEntity(
      title: params.title,
      description: params.description,
      content: params.content,
      author: params.author,
      userId: params.userId,
      thumbnailUrl: params.thumbnailUrl,
      status: params.status,
    );
  }
}
