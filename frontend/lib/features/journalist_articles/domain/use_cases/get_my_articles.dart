import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/journalist_article.dart';
import '../params/get_my_articles_params.dart';
import '../repository/journalist_article_repository.dart';

/// Lists the articles written by a journalist, optionally filtered by status
/// or by a search query.
class GetMyArticlesUseCase
    implements
        UseCase<DataState<List<JournalistArticleEntity>>, GetMyArticlesParams> {
  final JournalistArticleRepository _articleRepository;

  const GetMyArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<JournalistArticleEntity>>> call(
    GetMyArticlesParams params,
  ) {
    return _articleRepository.getUserArticles(
      userId: params.userId,
      status: params.status,
      searchQuery: params.searchQuery,
    );
  }
}
