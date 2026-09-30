import '../../domain/entities/article_draft.dart';
import '../../domain/entities/article_thumbnail.dart';

/// A draft as stored on the device.
class ArticleDraftModel extends ArticleDraftEntity {
  static const String titleField = 'title';
  static const String contentField = 'content';
  static const String authorField = 'author';
  static const String thumbnailPathField = 'thumbnailPath';
  static const String thumbnailSizeField = 'thumbnailSizeInBytes';

  const ArticleDraftModel({super.title, super.content, super.author, super.thumbnail});

  /// Throws a [FormatException] when [rawData] is not a stored draft.
  factory ArticleDraftModel.fromRawData(Map<String, dynamic> rawData) {
    final title = rawData[titleField];
    final content = rawData[contentField];
    final author = rawData[authorField];
    if (title is! String || content is! String || author is! String) {
      throw const FormatException('Stored draft without its text fields');
    }
    return ArticleDraftModel(title: title, content: content, author: author, thumbnail: _thumbnailOf(rawData));
  }

  static Map<String, dynamic> rawDataOf(ArticleDraftEntity draft) {
    return {
      titleField: draft.title,
      contentField: draft.content,
      authorField: draft.author,
      thumbnailPathField: draft.thumbnail?.localPath,
      thumbnailSizeField: draft.thumbnail?.sizeInBytes,
    };
  }

  static ArticleThumbnailEntity? _thumbnailOf(Map<String, dynamic> rawData) {
    final path = rawData[thumbnailPathField];
    final size = rawData[thumbnailSizeField];
    if (path is! String || size is! int) return null;
    return ArticleThumbnailEntity(localPath: path, sizeInBytes: size);
  }

  ArticleDraftEntity toEntity() {
    return ArticleDraftEntity(title: title, content: content, author: author, thumbnail: thumbnail);
  }
}
