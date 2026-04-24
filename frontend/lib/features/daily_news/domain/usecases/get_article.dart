import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/news_response.dart';
import '../repository/article_repository.dart';

class GetArticleUseCase implements UseCase<DataState<NewsResponse>, void> {
  final ArticleRepository _articleRepository;

  GetArticleUseCase(this._articleRepository);

  @override
  Future<DataState<NewsResponse>> call({void params}) {
    return _articleRepository.getNewsArticles();
  }
}
