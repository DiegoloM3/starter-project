import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../repository/article_repository.dart';

/// Latest articles of the authors the user does not follow yet, to discover new voices.
/// The articles of the followed authors have their own section.
class GetForYouArticlesUseCase implements UseCase<DataState<List<ArticleEntity>>, List<String>> {
  final ArticleRepository _articleRepository;

  GetForYouArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(List<String> followedAuthorIds) async {
    final result = await _articleRepository.getArticles();
    if (result is DataFailed) return result;
    final followed = followedAuthorIds.toSet();
    return DataSuccess(result.data!.where((article) => !followed.contains(article.authorId)).toList());
  }
}
