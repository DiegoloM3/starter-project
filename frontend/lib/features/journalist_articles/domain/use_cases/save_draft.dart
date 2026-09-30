import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_draft.dart';
import '../repository/article_draft_repository.dart';

/// Keeps the draft on the device. A blank draft deletes the saved one: there is nothing to resume.
class SaveDraftUseCase implements UseCase<DataState<void>, ArticleDraftEntity> {
  final ArticleDraftRepository _articleDraftRepository;

  SaveDraftUseCase(this._articleDraftRepository);

  @override
  Future<DataState<void>> call({ArticleDraftEntity? params}) {
    final draft = params ?? const ArticleDraftEntity();
    if (draft.isBlank) return _articleDraftRepository.deleteSavedDraft();
    return _articleDraftRepository.saveDraft(draft);
  }
}
