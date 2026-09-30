import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/published_article.dart';
import '../params/get_published_articles_params.dart';
import '../repository/published_article_repository.dart';

/// Returns one page of published articles, newest first.
class GetPublishedArticlesUseCase
    implements UseCase<DataState<List<PublishedArticleEntity>>, GetPublishedArticlesParams> {
  final PublishedArticleRepository _publishedArticleRepository;

  GetPublishedArticlesUseCase(this._publishedArticleRepository);

  @override
  Future<DataState<List<PublishedArticleEntity>>> call({GetPublishedArticlesParams? params}) {
    return _publishedArticleRepository.getPublishedArticles(params ?? const GetPublishedArticlesParams());
  }
}
