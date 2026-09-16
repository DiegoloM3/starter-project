import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';

/// Brings back the article left unfinished, if there is one.
class LoadDraftUseCase implements UseCase<SavedDraft?, NoParams> {
  final DraftRepository _drafts;

  const LoadDraftUseCase(this._drafts);

  @override
  Future<SavedDraft?> call(NoParams params) => _drafts.loadDraft();
}
