import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_article_model.dart';

/// Every query is scoped to the account that owns the bookmark.
@dao
abstract class SavedArticleDao {
  @Query('SELECT * FROM saved_article WHERE ownerId = :ownerId ORDER BY publishedAt DESC')
  Future<List<SavedArticleModel>> getArticles(String ownerId);

  @Query('SELECT * FROM saved_article WHERE ownerId = :ownerId AND id = :id')
  Future<SavedArticleModel?> findById(String ownerId, String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertArticle(SavedArticleModel article);

  @Query('DELETE FROM saved_article WHERE ownerId = :ownerId AND id = :id')
  Future<void> deleteById(String ownerId, String id);
}
