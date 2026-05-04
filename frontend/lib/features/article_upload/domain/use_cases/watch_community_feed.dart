import 'package:news_app_clean_architecture/core/usecase/stream_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class WatchCommunityFeedUseCase
    extends StreamUseCase<List<JournalistArticleEntity>, int> {
  final ArticleUploadRepository _repository;

  WatchCommunityFeedUseCase(this._repository);

  @override
  Stream<List<JournalistArticleEntity>> call({int? params}) {
    return _repository.watchCommunityFeed(limit: params ?? 20);
  }
}
