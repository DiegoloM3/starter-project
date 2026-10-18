import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../repository/article_repository.dart';

/// Articles of the given authors, newest first, for profiles and the following feed.
class GetArticlesByAuthorsUseCase implements UseCase<DataState<List<ArticleEntity>>, List<String>> {
  final ArticleRepository _articleRepository;

  GetArticlesByAuthorsUseCase(this._articleRepository);

  /// Without authors there is nothing to ask for, for example when the user follows nobody.
  @override
  Future<DataState<List<ArticleEntity>>> call(List<String> authorIds) async {
    if (authorIds.isEmpty) return const DataSuccess([]);
    return _articleRepository.getArticlesByAuthors(authorIds);
  }
}
