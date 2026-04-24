import '../repository/article_upload_repository.dart';

class UploadArticleThumbnailParams {
  final String localFilePath;
  final String authorId;

  const UploadArticleThumbnailParams({
    required this.localFilePath,
    required this.authorId,
  });
}

class UploadArticleThumbnailUseCase {
  final ArticleUploadRepository _repository;

  UploadArticleThumbnailUseCase(this._repository);

  Future<String> call(UploadArticleThumbnailParams params) {
    return _repository.uploadThumbnail(
      localFilePath: params.localFilePath,
      authorId: params.authorId,
    );
  }
}
