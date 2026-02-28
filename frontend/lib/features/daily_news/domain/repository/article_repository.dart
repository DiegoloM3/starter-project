import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  // API methods
  Future<DataState<List<ArticleEntity>>> getNewsArticles();

  // Database methods
  Future < List < ArticleEntity >> getSavedArticles();

  Future<DataState<List<ArticleEntity>>> getArticlesByAuthor(String authorId);

  Future<DataState<List<ArticleEntity>>> getCommunityArticles();

  Future<String> uploadArticleImage({
    required String authorId,
    required String localPath,
  });

  Future<void> deleteMyArticle(ArticleEntity article);

  Future < void > saveArticle(ArticleEntity article);
  Future < void > saveArticleLocally(ArticleEntity article);

  Future < void > removeArticle(ArticleEntity article);
}
