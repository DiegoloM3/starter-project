import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import 'mock/mock_articles.dart';

class GetSavedArticlesUseCase implements UseCase<DataState<List<ArticleEntity>>, NoParams> {
  @override
  Future<DataState<List<ArticleEntity>>> call(NoParams params) async {
    await Future.delayed(mockNetworkDelay);
    final mostRecentFirst = mockSavedArticleIds.toList().reversed;
    final savedArticles = mostRecentFirst.map(findMockArticle).whereType<ArticleEntity>().toList();
    return DataSuccess(savedArticles);
  }
}
