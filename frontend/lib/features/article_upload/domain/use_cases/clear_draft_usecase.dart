import '../repository/draft_repository.dart';

class ClearDraftUseCase {
  final DraftRepository _repository;
  const ClearDraftUseCase(this._repository);

  Future<void> call() => _repository.clearDraft();
}
