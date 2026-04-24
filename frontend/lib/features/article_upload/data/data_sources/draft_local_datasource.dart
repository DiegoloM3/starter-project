import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_draft_model.dart';

abstract interface class DraftLocalDataSource {
  Future<void> saveDraft(ArticleDraftModel draft);
  Future<ArticleDraftModel?> loadDraft();
  Future<void> clearDraft();
}

class DraftLocalDataSourceImpl implements DraftLocalDataSource {
  static const _key = 'article_draft';

  final SharedPreferences _prefs;
  const DraftLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveDraft(ArticleDraftModel draft) async {
    await _prefs.setString(_key, draft.toJsonString());
  }

  @override
  Future<ArticleDraftModel?> loadDraft() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    return ArticleDraftModel.fromJsonString(raw);
  }

  @override
  Future<void> clearDraft() async {
    await _prefs.remove(_key);
  }
}
