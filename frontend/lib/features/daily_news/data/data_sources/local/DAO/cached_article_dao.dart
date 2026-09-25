import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/cached_article_model.dart';

@dao
abstract class CachedArticleDao {
  @Query('SELECT * FROM cached_article WHERE category = :category '
      'ORDER BY position')
  Future<List<CachedArticleModel>> getCachedArticles(String category);

  @Query('DELETE FROM cached_article WHERE category = :category')
  Future<void> deleteCategory(String category);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertArticles(List<CachedArticleModel> articles);
}
