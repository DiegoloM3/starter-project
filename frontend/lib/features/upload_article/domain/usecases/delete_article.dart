import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/exceptions/upload_article_exceptions.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/user_article_repository.dart';

class DeleteArticleUseCase implements UseCase<void, String> {
  final UserArticleRepository _repository;

  DeleteArticleUseCase(this._repository);

  @override
  Future<void> call({String? params}) {
    if (params == null || params.isEmpty) {
      throw const InvalidArticleException('Article id is required.');
    }
    return _repository.deleteArticle(params);
  }
}
