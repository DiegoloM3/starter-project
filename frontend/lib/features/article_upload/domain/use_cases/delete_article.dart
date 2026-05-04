import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class DeleteArticleUseCase
    extends UseCase<DataState<void>, DeleteArticleParams> {
  final ArticleUploadRepository _repository;

  DeleteArticleUseCase(this._repository);

  @override
  Future<DataState<void>> call({DeleteArticleParams? params}) {
    assert(params != null, 'DeleteArticleParams must not be null');
    return _repository.delete(params!);
  }
}
