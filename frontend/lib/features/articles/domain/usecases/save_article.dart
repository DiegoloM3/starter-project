import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../exceptions/article_exceptions.dart';
import 'mock/mock_articles.dart';

class SaveArticleUseCase implements UseCase<DataState<void>, String> {
  @override
  Future<DataState<void>> call(String articleId) async {
    await Future.delayed(mockNetworkDelay);
    if (findMockArticle(articleId) == null) return DataFailed(ArticleNotFoundException(articleId));
    mockSavedArticleIds
      ..remove(articleId)
      ..add(articleId);
    return const DataSuccess(null);
  }
}
