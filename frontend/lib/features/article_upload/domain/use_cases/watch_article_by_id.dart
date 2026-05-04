import 'package:news_app_clean_architecture/core/usecase/stream_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class WatchArticleByIdUseCase
    extends StreamUseCase<JournalistArticleEntity?, String> {
  final ArticleUploadRepository _repository;

  WatchArticleByIdUseCase(this._repository);

  @override
  Stream<JournalistArticleEntity?> call({String? params}) {
    assert(params != null, 'articleId must not be null');
    return _repository.watchById(params!);
  }
}
