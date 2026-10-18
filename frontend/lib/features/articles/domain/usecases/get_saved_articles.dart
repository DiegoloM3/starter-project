import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../repository/saved_articles_repository.dart';

/// Most recently saved first.
class GetSavedArticlesUseCase implements UseCase<DataState<List<ArticleEntity>>, NoParams> {
  final SavedArticlesRepository _savedArticlesRepository;

  GetSavedArticlesUseCase(this._savedArticlesRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(NoParams params) => _savedArticlesRepository.getSavedArticles();
}
