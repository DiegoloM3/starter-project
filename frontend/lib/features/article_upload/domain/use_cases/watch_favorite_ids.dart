import 'package:news_app_clean_architecture/core/usecase/stream_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class WatchFavoriteIdsUseCase extends StreamUseCase<List<String>, String> {
  final ArticleUploadRepository _repository;

  WatchFavoriteIdsUseCase(this._repository);

  @override
  Stream<List<String>> call({String? params}) {
    assert(params != null, 'userId must not be null');
    return _repository.watchFavoriteArticleIds(params!);
  }
}
