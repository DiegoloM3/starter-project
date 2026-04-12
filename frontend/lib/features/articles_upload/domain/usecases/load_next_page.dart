import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/articles_upload_repository.dart';

class LoadNextPageUseCase
    implements UseCase<DataState<List<ArticleUploadEntity>>, DateTime> {
  final ArticlesUploadRepository _repository;

  LoadNextPageUseCase(this._repository);

  @override
  Future<DataState<List<ArticleUploadEntity>>> call({DateTime? params}) {
    if (params == null) {
      throw ArgumentError(
          'LoadNextPageUseCase requires a lastPublishedAt date');
    }
    return _repository.fetchNextPage(params);
  }
}
