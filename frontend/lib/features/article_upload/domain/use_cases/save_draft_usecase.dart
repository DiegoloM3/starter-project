import '../entities/article_draft_entity.dart';
import '../repository/draft_repository.dart';

class SaveDraftUseCase {
  final DraftRepository _repository;
  const SaveDraftUseCase(this._repository);

  Future<void> call(ArticleDraftEntity draft) => _repository.saveDraft(draft);
}
