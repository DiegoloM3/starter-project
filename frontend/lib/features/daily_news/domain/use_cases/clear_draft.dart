import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';

/// Forgets the unfinished article: after publishing it, or on request.
class ClearDraftUseCase implements UseCase<DataState<void>, NoParams> {
  final DraftRepository _drafts;

  const ClearDraftUseCase(this._drafts);

  @override
  Future<DataState<void>> call(NoParams params) => _drafts.clearDraft();
}
