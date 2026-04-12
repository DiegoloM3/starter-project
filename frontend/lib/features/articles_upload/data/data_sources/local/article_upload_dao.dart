import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/articles_upload/data/data_sources/local/article_upload_floor_entity.dart';

@dao
abstract class ArticleUploadDao {
  @Query(
    'SELECT * FROM article_upload WHERE deletedAt IS NULL '
    'ORDER BY publishedAt DESC',
  )
  Future<List<ArticleUploadFloorEntity>> getAllLive();

  @Query('SELECT * FROM article_upload ORDER BY publishedAt DESC')
  Future<List<ArticleUploadFloorEntity>> getAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertArticle(ArticleUploadFloorEntity entity);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertAll(List<ArticleUploadFloorEntity> entities);

  @Query('DELETE FROM article_upload WHERE id = :id')
  Future<void> removeById(String id);

  @Query('DELETE FROM article_upload')
  Future<void> clearAll();
}
