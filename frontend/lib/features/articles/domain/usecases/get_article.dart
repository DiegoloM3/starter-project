import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../repository/article_repository.dart';

class GetArticleUseCase implements UseCase<DataState<ArticleEntity>, String> {
  final ArticleRepository _articleRepository;

  GetArticleUseCase(this._articleRepository);

  @override
  Future<DataState<ArticleEntity>> call(String articleId) => _articleRepository.getArticle(articleId);
}
