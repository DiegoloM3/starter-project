import '../entities/article_upload_entity.dart';
import '../repository/article_upload_repository.dart';

class GetMyArticlesUseCase {
  final ArticleUploadRepository _repository;

  GetMyArticlesUseCase(this._repository);

  Future<List<ArticleUploadEntity>> call(String authorId) {
    return _repository.getMyArticles(authorId);
  }
}
