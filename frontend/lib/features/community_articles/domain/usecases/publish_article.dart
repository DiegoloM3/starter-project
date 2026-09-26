import '../../../../core/resources/data_state.dart';
import '../entities/community_article.dart';
import '../params/publish_article_params.dart';
import '../repository/community_article_repository.dart';

class PublishArticleUseCase {
  final CommunityArticleRepository _repository;

  const PublishArticleUseCase(this._repository);

  Future<DataState<CommunityArticleEntity>> call(PublishArticleParams params) {
    final title = params.title.trim();
    final content = params.content.trim();
    if (title.length < 5 || title.length > 120) {
      return Future.value(const DataFailed(AppFailure(
        'Title must be between 5 and 120 characters.',
      )));
    }
    if (content.length < 20 || content.length > 10000) {
      return Future.value(const DataFailed(AppFailure(
        'Article body must be between 20 and 10,000 characters.',
      )));
    }
    final image = params.image;
    if (image == null) {
      return Future.value(const DataFailed(AppFailure(
        'Attach a JPEG, PNG, or WebP image before publishing.',
      )));
    }
    if (image.sizeInBytes == 0 || image.sizeInBytes > 5 * 1024 * 1024) {
      return Future.value(const DataFailed(AppFailure(
        'Images must be between 1 byte and 5 MB.',
      )));
    }
    if (!image.isSupportedRaster) {
      return Future.value(const DataFailed(AppFailure(
        'The selected file is not a valid JPEG, PNG, or WebP image.',
      )));
    }
    return _repository.publishArticle(PublishArticleParams(
      clientId: params.clientId,
      title: title,
      content: content,
      image: image,
    ));
  }
}
