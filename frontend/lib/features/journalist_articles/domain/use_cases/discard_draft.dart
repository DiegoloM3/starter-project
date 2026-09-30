import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../repository/article_draft_repository.dart';

class DiscardDraftUseCase implements UseCase<DataState<void>, void> {
  final ArticleDraftRepository _articleDraftRepository;

  DiscardDraftUseCase(this._articleDraftRepository);

  @override
  Future<DataState<void>> call({void params}) {
    return _articleDraftRepository.deleteSavedDraft();
  }
}
