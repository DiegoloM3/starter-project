import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/journalist_article.dart';
import '../params/get_published_articles_params.dart';
import '../repository/journalist_article_repository.dart';

/// Lists articles open to every reader.
///
/// The same operation serves two callers: the general feed of published
/// articles (no `authorId`) and "more articles from this journalist"
/// (`authorId` set to that journalist).
class GetPublishedArticlesUseCase
    implements
        UseCase<DataState<List<JournalistArticleEntity>>,
            GetPublishedArticlesParams> {
  final JournalistArticleRepository _articleRepository;

  const GetPublishedArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<JournalistArticleEntity>>> call(
    GetPublishedArticlesParams params,
  ) {
    return _articleRepository.getPublishedArticles(
      limit: params.limit,
      authorId: params.authorId,
      excludeArticleId: params.excludeArticleId,
      startAfterArticleId: params.startAfterArticleId,
      publishedAfter: params.publishedAfter,
    );
  }
}
