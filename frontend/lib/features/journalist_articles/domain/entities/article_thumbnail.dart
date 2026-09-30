import 'package:equatable/equatable.dart';

/// An image picked by the journalist to illustrate an article, before it is uploaded.
///
/// Mirrors the constraints of `backend/storage.rules` (see backend/docs/DB_SCHEMA.md).
class ArticleThumbnailEntity extends Equatable {
  static const int maxSizeInBytes = 5 * 1024 * 1024;
  static const Set<String> supportedExtensions = {'jpg', 'png', 'webp'};

  final String localPath;
  final int sizeInBytes;

  const ArticleThumbnailEntity({required this.localPath, required this.sizeInBytes});

  /// Lowercase extension, with `jpeg` normalized to `jpg` (the name stored in Cloud Storage).
  String get extension {
    final extension = _rawExtension.toLowerCase();
    return extension == 'jpeg' ? 'jpg' : extension;
  }

  bool get isSupportedFormat => supportedExtensions.contains(extension);

  bool get exceedsMaxSize => sizeInBytes > maxSizeInBytes;

  String get _rawExtension {
    final fileName = localPath.split('/').last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex == -1 ? '' : fileName.substring(dotIndex + 1);
  }

  @override
  List<Object?> get props => [localPath, sizeInBytes];
}
