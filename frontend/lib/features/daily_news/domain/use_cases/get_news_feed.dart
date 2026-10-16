import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_published_articles.dart';

/// Builds the home feed: the articles published by journalists together with
/// the articles of the news API, newest first. The feed is still shown when
/// only one of the two sources is available.
class GetNewsFeedUseCase implements UseCase<DataState<List<ArticleEntity>>, void> {
  final GetArticleUseCase _getNewsArticles;
  final GetPublishedArticlesUseCase _getPublishedArticles;

  GetNewsFeedUseCase(this._getNewsArticles, this._getPublishedArticles);

  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) async {
    final newsArticles = await _getNewsArticles();
    final publishedArticles = await _getPublishedArticles();
    if (newsArticles is DataFailed && publishedArticles is DataFailed) {
      return DataFailed(newsArticles.error!);
    }
    return DataSuccess(_sortByNewestFirst([
      ...?publishedArticles.data,
      ...?newsArticles.data,
    ]));
  }

  List<ArticleEntity> _sortByNewestFirst(List<ArticleEntity> articles) {
    return List.of(articles)
      ..sort((first, second) => _readPublicationDate(second).compareTo(_readPublicationDate(first)));
  }

  DateTime _readPublicationDate(ArticleEntity article) {
    return article.publicationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
