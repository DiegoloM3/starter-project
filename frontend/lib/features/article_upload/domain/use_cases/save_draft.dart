import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/save_draft_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class SaveDraftUseCase extends UseCase<DataState<int>, SaveDraftParams> {
  final ArticleUploadRepository _repository;

  SaveDraftUseCase(this._repository);

  @override
  Future<DataState<int>> call({SaveDraftParams? params}) {
    assert(params != null, 'SaveDraftParams must not be null');
    return _repository.saveDraft(params!);
  }
}
