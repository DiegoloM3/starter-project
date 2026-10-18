import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../repository/article_repository.dart';

/// Newest first.
class GetArticlesUseCase implements UseCase<DataState<List<ArticleEntity>>, NoParams> {
  final ArticleRepository _articleRepository;

  GetArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(NoParams params) => _articleRepository.getArticles();
}
