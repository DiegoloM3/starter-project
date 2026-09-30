import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../entities/article_draft.dart';

/// The article the journalist is writing, kept on the device so it survives leaving the form,
/// closing the app or a crash.
abstract class ArticleDraftRepository {
  /// Succeeds with `null` when there is no saved draft.
  Future<DataState<ArticleDraftEntity?>> getSavedDraft();

  Future<DataState<void>> saveDraft(ArticleDraftEntity draft);

  Future<DataState<void>> deleteSavedDraft();
}
