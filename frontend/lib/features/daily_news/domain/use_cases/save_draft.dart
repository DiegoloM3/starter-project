import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';

/// Keeps the current draft. An empty one is not stored: the form was wiped,
/// so whatever was kept before is dropped instead.
class SaveDraftUseCase implements UseCase<DataState<void>, SavedDraft> {
  final DraftRepository _drafts;

  const SaveDraftUseCase(this._drafts);

  @override
  Future<DataState<void>> call(SavedDraft params) =>
      params.isEmpty ? _drafts.clearDraft() : _drafts.saveDraft(params);
}
