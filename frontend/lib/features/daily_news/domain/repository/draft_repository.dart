import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';

/// Keeps the single unfinished article on the device.
abstract interface class DraftRepository {
  /// The draft left behind, or `null` when there is none worth restoring.
  Future<SavedDraft?> loadDraft();

  Future<DataState<void>> saveDraft(SavedDraft draft);

  Future<DataState<void>> clearDraft();
}
