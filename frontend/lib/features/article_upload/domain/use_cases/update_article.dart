import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class UpdateArticleUseCase
    extends UseCase<DataState<JournalistArticleEntity>, UpdateArticleParams> {
  final ArticleUploadRepository _repository;

  UpdateArticleUseCase(this._repository);

  @override
  Future<DataState<JournalistArticleEntity>> call(
      {UpdateArticleParams? params}) {
    assert(params != null, 'UpdateArticleParams must not be null');
    return _repository.update(params!);
  }
}
