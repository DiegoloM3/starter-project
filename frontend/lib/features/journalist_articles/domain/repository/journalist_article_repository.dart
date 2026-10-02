import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

abstract class JournalistArticleRepository {
  Future<DataState<List<JournalistArticleEntity>>> getPublishedArticles();

  Future<DataState<JournalistArticleEntity>> publishArticle(
    ArticleDraftEntity draft,
  );
}
