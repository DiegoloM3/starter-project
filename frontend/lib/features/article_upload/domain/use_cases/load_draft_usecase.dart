import '../entities/article_draft_entity.dart';
import '../repository/draft_repository.dart';

class LoadDraftUseCase {
  final DraftRepository _repository;
  const LoadDraftUseCase(this._repository);

  Future<ArticleDraftEntity?> call() => _repository.loadDraft();
}
