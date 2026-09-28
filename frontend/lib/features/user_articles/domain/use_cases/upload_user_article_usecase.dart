import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import '../params/upload_user_article_params.dart';
import '../repository/user_article_repository.dart';

class UploadUserArticleUseCase
    implements UseCase<DataState<void>, UploadUserArticleParams> {
  final UserArticleRepository _repository;
  UploadUserArticleUseCase({required UserArticleRepository repository})
      : _repository = repository;

  @override
  Future<DataState<void>> call({UploadUserArticleParams? params}) {
    return _repository.uploadArticle(params!);
  }
}
