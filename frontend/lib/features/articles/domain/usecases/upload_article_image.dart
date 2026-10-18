import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../exceptions/article_exceptions.dart';
import '../params/article_image.dart';
import 'mock/mock_articles.dart';

/// Uploads an image embedded in the article content and returns its URL.
class UploadArticleImageUseCase implements UseCase<DataState<String>, ArticleImage> {
  @override
  Future<DataState<String>> call(ArticleImage image) async {
    final errors = image.validationErrors;
    if (errors.isNotEmpty) return DataFailed(ArticleValidationException(errors));

    await Future.delayed(mockNetworkDelay);
    return const DataSuccess(mockImageURL);
  }
}
