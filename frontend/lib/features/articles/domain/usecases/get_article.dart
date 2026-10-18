import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../exceptions/article_exceptions.dart';
import 'mock/mock_articles.dart';

class GetArticleUseCase implements UseCase<DataState<ArticleEntity>, String> {
  @override
  Future<DataState<ArticleEntity>> call(String articleId) async {
    await Future.delayed(mockNetworkDelay);
    final article = findMockArticle(articleId);
    if (article == null) return DataFailed(ArticleNotFoundException(articleId));
    return DataSuccess(article);
  }
}
