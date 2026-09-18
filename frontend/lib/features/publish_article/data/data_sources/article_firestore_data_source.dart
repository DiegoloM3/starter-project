import '../../domain/params/publish_article_params.dart';
import '../models/publishable_article_model.dart';

abstract class ArticleFirestoreDataSource {
  String createArticleId();

  Future<void> createArticle({
    required String articleId,
    required PublishArticleParams params,
    required String thumbnailUrl,
  });

  Future<PublishableArticleModel> getArticleById(String articleId);
}
