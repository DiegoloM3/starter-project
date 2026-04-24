import '../entities/article_draft_entity.dart';

abstract interface class DraftRepository {
  Future<void> saveDraft(ArticleDraftEntity draft);
  Future<ArticleDraftEntity?> loadDraft();
  Future<void> clearDraft();
}
