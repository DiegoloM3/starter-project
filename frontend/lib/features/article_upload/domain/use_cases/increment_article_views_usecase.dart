import '../repository/article_upload_repository.dart';

class IncrementArticleViewsUseCase {
  final ArticleUploadRepository _repository;
  const IncrementArticleViewsUseCase(this._repository);

  Future<void> call(String articleId) => _repository.incrementArticleViews(articleId);
}
