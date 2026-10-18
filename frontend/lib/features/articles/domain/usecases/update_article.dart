import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../exceptions/article_exceptions.dart';
import '../params/update_article_params.dart';
import 'mock/mock_articles.dart';

class UpdateArticleUseCase implements UseCase<DataState<ArticleEntity>, UpdateArticleParams> {
  @override
  Future<DataState<ArticleEntity>> call(UpdateArticleParams params) async {
    final errors = params.validationErrors;
    if (errors.isNotEmpty) return DataFailed(ArticleValidationException(errors));

    await Future.delayed(mockNetworkDelay);
    final original = findMockArticle(params.articleId);
    if (original == null) return DataFailed(ArticleNotFoundException(params.articleId));
    return DataSuccess(_applyChanges(original, params));
  }

  ArticleEntity _applyChanges(ArticleEntity original, UpdateArticleParams params) {
    return original.copyWith(
      title: params.draft.title,
      description: params.draft.description,
      content: params.draft.content,
      topics: params.draft.topics.toList(),
      thumbnailURL: params.newThumbnail == null ? null : mockImageURL,
    );
  }
}
