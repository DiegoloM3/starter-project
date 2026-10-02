import 'dart:typed_data';

import 'package:news_app_clean_architecture/core/util/value_equality.dart';

/// Image chosen by the journalist as the thumbnail of an article.
class ArticleThumbnailEntity with ValueEquality {
  static const int maxSizeInBytes = 5 * 1024 * 1024;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  final Uint8List bytes;
  final String fileExtension;

  const ArticleThumbnailEntity({
    required this.bytes,
    required this.fileExtension,
  });

  bool get hasAllowedExtension =>
      allowedExtensions.contains(fileExtension.toLowerCase());

  bool get isWithinMaxSize => bytes.length <= maxSizeInBytes;

  @override
  List<Object?> get props => [bytes, fileExtension];
}
