import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import 'mock/mock_articles.dart';

class GetArticlesUseCase implements UseCase<DataState<List<ArticleEntity>>, NoParams> {
  @override
  Future<DataState<List<ArticleEntity>>> call(NoParams params) async {
    await Future.delayed(mockNetworkDelay);
    final newestFirst = [...mockArticles]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return DataSuccess(newestFirst);
  }
}
