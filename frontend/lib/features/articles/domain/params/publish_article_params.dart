import 'article_draft.dart';
import 'article_image.dart';

class PublishArticleParams {
  final ArticleDraft draft;
  final ArticleImage thumbnail;

  const PublishArticleParams({required this.draft, required this.thumbnail});

  Set<ArticleValidationError> get validationErrors => {...draft.validationErrors, ...thumbnail.validationErrors};
}
