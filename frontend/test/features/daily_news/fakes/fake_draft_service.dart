import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/draft_service.dart';

class FakeDraftService implements DraftService {
  DraftArticle? savedDraft;
  bool clearCalled = false;

  @override
  Future<void> ensureTableCreated() async {}

  @override
  Future<void> saveDraft(DraftArticle draft) async {
    savedDraft = draft;
  }

  @override
  Future<DraftArticle?> loadDraft() async => savedDraft;

  @override
  Future<void> clearDraft() async {
    clearCalled = true;
    savedDraft = null;
  }
}
