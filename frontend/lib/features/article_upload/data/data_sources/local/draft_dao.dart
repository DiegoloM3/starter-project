import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/models/draft_article_model.dart';

@dao
abstract class DraftDao {
  @Query('SELECT * FROM draft_articles ORDER BY lastSavedAtMillis DESC')
  Stream<List<DraftArticleModel>> watchDrafts();

  @Query('SELECT * FROM draft_articles WHERE draftId = :id')
  Future<DraftArticleModel?> getDraft(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> upsertDraft(DraftArticleModel draft);

  @Query('DELETE FROM draft_articles WHERE draftId = :id')
  Future<void> deleteDraft(int id);

  @Query('DELETE FROM draft_articles')
  Future<void> deleteAllDrafts();
}
