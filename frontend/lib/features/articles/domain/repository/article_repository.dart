import '../../../../core/resources/data_state.dart';
import '../entities/article.dart';
import '../params/article_image.dart';
import '../params/publish_article_params.dart';
import '../params/update_article_params.dart';

abstract class ArticleRepository {
  Future<DataState<List<ArticleEntity>>> getArticles();

  Future<DataState<ArticleEntity>> getArticle(String articleId);

  /// Newest first.
  Future<DataState<List<ArticleEntity>>> getArticlesByAuthors(List<String> authorIds);

  /// Publishes the article in the name of the signed in journalist.
  Future<DataState<ArticleEntity>> publishArticle(PublishArticleParams params);

  Future<DataState<ArticleEntity>> updateArticle(UpdateArticleParams params);

  Future<DataState<void>> deleteArticle(String articleId);

  /// Uploads an image embedded in the article content and returns its URL.
  Future<DataState<String>> uploadArticleImage(ArticleImage image);
}
