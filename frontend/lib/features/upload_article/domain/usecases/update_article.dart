import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/exceptions/upload_article_exceptions.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/params/update_article_params.dart';

class UpdateArticleUseCase
    implements UseCase<UserArticleEntity, UpdateArticleParams> {
  final UserArticleRepository _repository;

  UpdateArticleUseCase(this._repository);

  @override
  Future<UserArticleEntity> call({UpdateArticleParams? params}) {
    if (params == null) {
      throw const InvalidArticleException('Missing article fields.');
    }
    _validate(params);
    return _repository.updateArticle(params);
  }

  void _validate(UpdateArticleParams p) {
    if (p.articleId.isEmpty) {
      throw const InvalidArticleException('Article id is required.');
    }
    if (p.title.trim().isEmpty || p.title.trim().length > 120) {
      throw const InvalidArticleException('Title must be 1-120 characters.');
    }
    if (p.description.trim().isEmpty || p.description.trim().length > 500) {
      throw const InvalidArticleException(
          'Description must be 1-500 characters.');
    }
    if (p.content.trim().isEmpty || p.content.trim().length > 20000) {
      throw const InvalidArticleException(
          'Content must be 1-20000 characters.');
    }
  }
}
