import 'package:news_app_clean_architecture/core/usecase/stream_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class WatchMyArticlesUseCase
    extends StreamUseCase<List<JournalistArticleEntity>, String> {
  final ArticleUploadRepository _repository;

  WatchMyArticlesUseCase(this._repository);

  @override
  Stream<List<JournalistArticleEntity>> call({String? params}) {
    assert(params != null, 'userId must not be null');
    return _repository.watchByAuthor(params!);
  }
}
