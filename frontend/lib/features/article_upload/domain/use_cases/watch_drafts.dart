import 'package:news_app_clean_architecture/core/usecase/stream_usecase.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class WatchDraftsUseCase
    extends StreamUseCase<List<DraftArticleEntity>, NoParams> {
  final ArticleUploadRepository _repository;

  WatchDraftsUseCase(this._repository);

  @override
  Stream<List<DraftArticleEntity>> call({NoParams? params}) {
    return _repository.watchDrafts();
  }
}
