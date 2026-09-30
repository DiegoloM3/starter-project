import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_draft.dart';
import '../repository/article_draft_repository.dart';
import '../repository/author_signature_repository.dart';

/// The draft the journalist continues with when opening the form: the one saved on the device,
/// or else a new one signed with the signature of their previous article.
class ResumeDraftUseCase implements UseCase<DataState<ArticleDraftEntity>, void> {
  final ArticleDraftRepository _articleDraftRepository;
  final AuthorSignatureRepository _authorSignatureRepository;

  ResumeDraftUseCase(this._articleDraftRepository, this._authorSignatureRepository);

  @override
  Future<DataState<ArticleDraftEntity>> call({void params}) async {
    // A draft that cannot be read is treated as no draft: the journalist can always start over.
    final savedDraft = (await _articleDraftRepository.getSavedDraft()).data;
    if (savedDraft != null && !savedDraft.isBlank) return DataSuccess(savedDraft);
    final authorName = (await _authorSignatureRepository.getSavedAuthorName()).data;
    return DataSuccess(ArticleDraftEntity(author: authorName ?? ''));
  }
}
