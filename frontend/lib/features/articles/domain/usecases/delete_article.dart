import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/article_repository.dart';

class DeleteArticleUseCase implements UseCase<DataState<void>, String> {
  final ArticleRepository _articleRepository;

  DeleteArticleUseCase(this._articleRepository);

  @override
  Future<DataState<void>> call(String articleId) => _articleRepository.deleteArticle(articleId);
}
