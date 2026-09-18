import '../models/publishable_article_model.dart';

abstract class PublishedArticlesFirestoreDataSource {
  Future<List<PublishableArticleModel>> getPublishedArticles();
}
