import 'article_draft.dart';
import 'article_image.dart';

class UpdateArticleParams {
  final String articleId;
  final ArticleDraft draft;

  /// Null keeps the current thumbnail.
  final ArticleImage? newThumbnail;

  const UpdateArticleParams({required this.articleId, required this.draft, this.newThumbnail});

  Set<ArticleValidationError> get validationErrors => {...draft.validationErrors, ...?newThumbnail?.validationErrors};
}
