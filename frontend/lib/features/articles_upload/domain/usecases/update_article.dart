import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/articles_upload_repository.dart';

class UpdateArticleUseCase
    implements UseCase<DataState<ArticleUploadEntity>, UpdateArticleParams> {
  final ArticlesUploadRepository _repository;

  UpdateArticleUseCase(this._repository);

  @override
  Future<DataState<ArticleUploadEntity>> call({
    UpdateArticleParams? params,
  }) {
    if (params == null) {
      throw ArgumentError('UpdateArticleUseCase requires non-null params');
    }
    return _repository.updateArticle(params);
  }
}
