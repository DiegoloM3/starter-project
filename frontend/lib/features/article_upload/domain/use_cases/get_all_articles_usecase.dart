import '../entities/article_upload_entity.dart';
import '../repository/article_upload_repository.dart';

class GetAllArticlesUseCase {
  final ArticleUploadRepository _repository;

  GetAllArticlesUseCase(this._repository);

  Future<List<ArticleUploadEntity>> call() => _repository.getAllArticles();
}
