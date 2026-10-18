import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../exceptions/article_exceptions.dart';
import '../params/article_image.dart';
import '../repository/article_repository.dart';

/// Uploads an image embedded in the article content and returns its URL.
class UploadArticleImageUseCase implements UseCase<DataState<String>, ArticleImage> {
  final ArticleRepository _articleRepository;

  UploadArticleImageUseCase(this._articleRepository);

  @override
  Future<DataState<String>> call(ArticleImage image) async {
    final errors = image.validationErrors;
    if (errors.isNotEmpty) return DataFailed(ArticleValidationException(errors));
    return _articleRepository.uploadArticleImage(image);
  }
}
