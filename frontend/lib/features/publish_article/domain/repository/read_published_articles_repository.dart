import '../entities/publishable_article.dart';

abstract class ReadPublishedArticlesRepository {
  Future<List<PublishableArticle>> getPublishedArticles();
}
