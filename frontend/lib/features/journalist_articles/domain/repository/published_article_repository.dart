import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../entities/article_draft.dart';
import '../entities/published_article.dart';
import '../params/get_published_articles_params.dart';

abstract class PublishedArticleRepository {
  /// Uploads the thumbnail and stores the article. The draft must be valid and trimmed.
  Future<DataState<void>> publishArticle(ArticleDraftEntity draft);

  Future<DataState<List<PublishedArticleEntity>>> getPublishedArticles(GetPublishedArticlesParams params);
}
