import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Same reasoning as GetUserArticleByIdUseCase: a single id doesn't need a
/// dedicated Params class. Returns `DataState<bool>` rather than
/// `DataState<void>` -- void isn't a meaningful value to wrap in DataSuccess.
class DeleteUserArticleUseCase implements UseCase<DataState<bool>, String> {
  final UserArticleRepository _repository;

  DeleteUserArticleUseCase(this._repository);

  @override
  Future<DataState<bool>> call({String? params}) {
    if (params == null) {
      return Future.value(const DataSuccess(false));
    }
    return _repository.deleteArticle(params);
  }
}
