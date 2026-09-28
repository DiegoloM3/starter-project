import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_model.dart';

@dao
abstract class ArticleDao {

  @Insert()
  Future<void> insertArticle(ArticleModel article);

  @Query('DELETE FROM article WHERE url = :url')
  Future<void> deleteArticleByUrl(String url);

  @Query('SELECT * FROM article')
  Future<List<ArticleModel>> getArticles();
}