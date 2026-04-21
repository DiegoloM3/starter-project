import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/exceptions/upload_article_exceptions.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/params/upload_article_params.dart';

class UploadArticleUseCase
    implements UseCase<UserArticleEntity, UploadArticleParams> {
  final UserArticleRepository _repository;

  UploadArticleUseCase(this._repository);

  @override
  Future<UserArticleEntity> call({UploadArticleParams? params}) {
    if (params == null) {
      throw const InvalidArticleException('Missing article fields.');
    }
    _validate(params);
    return _repository.uploadArticle(params);
  }

  void _validate(UploadArticleParams p) {
    if (p.title.trim().isEmpty) {
      throw const InvalidArticleException('Title is required.');
    }
    if (p.title.trim().length > 120) {
      throw const InvalidArticleException(
          'Title must be 120 characters or fewer.');
    }
    if (p.description.trim().isEmpty) {
      throw const InvalidArticleException('Description is required.');
    }
    if (p.content.trim().isEmpty) {
      throw const InvalidArticleException('Content is required.');
    }
    if (p.thumbnailBytes.isEmpty) {
      throw const InvalidArticleException('Thumbnail image is required.');
    }
  }
}
