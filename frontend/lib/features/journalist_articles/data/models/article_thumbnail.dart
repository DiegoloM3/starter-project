import 'dart:typed_data';

import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

/// Thumbnail as it is read from the gallery and uploaded to Cloud Storage (`media/articles`).
class ArticleThumbnailModel extends ArticleThumbnailEntity {
  const ArticleThumbnailModel({required super.bytes, required super.fileExtension});

  /// [fileName] is the name of the image file, used to know its type (`photo.JPG` → `jpg`).
  factory ArticleThumbnailModel.fromRawData(Uint8List bytes, String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    final fileExtension = dotIndex == -1 ? '' : fileName.substring(dotIndex + 1).toLowerCase();
    return ArticleThumbnailModel(bytes: bytes, fileExtension: fileExtension);
  }

  factory ArticleThumbnailModel.fromEntity(ArticleThumbnailEntity entity) {
    return ArticleThumbnailModel(
      bytes: entity.bytes,
      fileExtension: entity.fileExtension.toLowerCase(),
    );
  }

  /// Content type required by storage.rules for the uploaded file.
  String get contentType {
    switch (fileExtension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  ArticleThumbnailEntity toEntity() {
    return ArticleThumbnailEntity(bytes: bytes, fileExtension: fileExtension);
  }
}
