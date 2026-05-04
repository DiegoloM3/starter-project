import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/draft_id_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class DeleteDraftUseCase extends UseCase<DataState<void>, DraftIdParams> {
  final ArticleUploadRepository _repository;

  DeleteDraftUseCase(this._repository);

  @override
  Future<DataState<void>> call({DraftIdParams? params}) {
    assert(params != null, 'DraftIdParams must not be null');
    return _repository.deleteDraft(params!);
  }
}
