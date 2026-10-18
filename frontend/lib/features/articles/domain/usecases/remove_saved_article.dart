import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/saved_articles_repository.dart';

class RemoveSavedArticleUseCase implements UseCase<DataState<void>, String> {
  final SavedArticlesRepository _savedArticlesRepository;

  RemoveSavedArticleUseCase(this._savedArticlesRepository);

  @override
  Future<DataState<void>> call(String articleId) => _savedArticlesRepository.removeSavedArticle(articleId);
}
