import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/published_article.dart';

abstract class PublishedArticleRepository {
  Future<DataState<void>> publishArticle(ArticleDraftEntity draft);

  Future<DataState<List<PublishedArticleEntity>>> getPublishedArticles();
}
