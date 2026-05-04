import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/toggle_favorite_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class ToggleFavoriteUseCase
    extends UseCase<DataState<void>, ToggleFavoriteParams> {
  final ArticleUploadRepository _repository;

  ToggleFavoriteUseCase(this._repository);

  @override
  Future<DataState<void>> call({ToggleFavoriteParams? params}) {
    assert(params != null, 'ToggleFavoriteParams must not be null');
    return _repository.toggleFavorite(params!);
  }
}
