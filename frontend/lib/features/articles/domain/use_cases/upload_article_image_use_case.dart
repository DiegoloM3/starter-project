import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/params/upload_article_image_params.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class UploadArticleImageUseCase
    implements UseCase<DataState<String>, UploadArticleImageParams> {
  final ArticleRepository _repository;
  UploadArticleImageUseCase(this._repository);

  @override
  Future<DataState<String>> call(UploadArticleImageParams params) {
    return _repository.uploadArticleImage(params);
  }
}
