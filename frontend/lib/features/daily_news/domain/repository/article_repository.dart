import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';

abstract class ArticleRepository {
  // API methods
  Future<DataState<List<ArticleEntity>>> getNewsArticles();

  // Database methods (saved articles)
  Future<List<ArticleEntity>> getSavedArticles();

  Future<void> saveArticle(ArticleEntity article);

  Future<void> removeArticle(ArticleEntity article);

  // Article upload methods
  Future<DataState<ArticleEntity>> uploadArticle(CreateArticleParams params);

  Future<DataState<ArticleEntity>> updateArticle(UpdateArticleParams params);

  Future<DataState<void>> deleteArticle(DeleteArticleParams params);

  Future<DataState<List<ArticleEntity>>> getUserArticles(
    GetUserArticlesParams params,
  );

  Future<DataState<void>> updateArticlePublishStatus(
    UpdatePublishStatusParams params,
  );
}