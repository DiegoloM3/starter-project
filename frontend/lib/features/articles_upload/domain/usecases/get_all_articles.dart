import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/articles_upload_repository.dart';

class GetAllArticlesUseCase
    implements UseCase<DataState<List<ArticleUploadEntity>>, void> {
  final ArticlesUploadRepository _repository;

  GetAllArticlesUseCase(this._repository);

  @override
  Future<DataState<List<ArticleUploadEntity>>> call({void params}) {
    return _repository.getAllArticles();
  }
}
