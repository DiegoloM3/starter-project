import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/articles_upload_repository.dart';

class CreateArticleUseCase
    implements UseCase<DataState<ArticleUploadEntity>, CreateArticleParams> {
  final ArticlesUploadRepository _repository;

  CreateArticleUseCase(this._repository);

  @override
  Future<DataState<ArticleUploadEntity>> call({
    CreateArticleParams? params,
  }) {
    if (params == null) {
      throw ArgumentError('CreateArticleUseCase requires non-null params');
    }
    return _repository.createArticle(params);
  }
}
