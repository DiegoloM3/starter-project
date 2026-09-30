import '../../domain/entities/article_thumbnail.dart';

class ArticleThumbnailModel extends ArticleThumbnailEntity {
  const ArticleThumbnailModel({required super.localPath, required super.sizeInBytes});

  factory ArticleThumbnailModel.fromRawData({required String localPath, required int sizeInBytes}) {
    return ArticleThumbnailModel(localPath: localPath, sizeInBytes: sizeInBytes);
  }

  ArticleThumbnailEntity toEntity() {
    return ArticleThumbnailEntity(localPath: localPath, sizeInBytes: sizeInBytes);
  }
}
