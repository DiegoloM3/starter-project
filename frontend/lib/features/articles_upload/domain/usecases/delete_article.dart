import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/articles_upload_repository.dart';

class DeleteArticleUseCase implements UseCase<DataState<void>, String> {
  final ArticlesUploadRepository _repository;

  DeleteArticleUseCase(this._repository);

  @override
  Future<DataState<void>> call({String? params}) {
    if (params == null || params.isEmpty) {
      throw ArgumentError('DeleteArticleUseCase requires a non-empty id');
    }
    return _repository.deleteArticle(params);
  }
}
