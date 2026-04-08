import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class CommunityArticleRepository {
  /// Streams the most recent community articles, newest first.
  Stream<List<ArticleEntity>> watchArticles();

  /// Publishes a new article and returns the Firestore document ID.
  Future<String> publishArticle(ArticleEntity article);
}
