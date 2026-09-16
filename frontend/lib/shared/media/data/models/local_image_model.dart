import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';

/// A picked file as the platform describes it. The MIME type is taken from
/// the platform when given, otherwise from the file extension.
class LocalImageModel extends LocalImage {
  const LocalImageModel({
    required super.path,
    required super.mimeType,
    required super.sizeInBytes,
  });

  factory LocalImageModel.fromRawData({
    required String path,
    required int sizeInBytes,
    String? mimeType,
  }) {
    return LocalImageModel(
      path: path,
      mimeType: mimeType ?? mimeTypeForPath(path),
      sizeInBytes: sizeInBytes,
    );
  }

  static String mimeTypeForPath(String path) {
    final dot = path.lastIndexOf('.');
    final extension = dot < 0 ? '' : path.substring(dot + 1).toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'heic' => 'image/heic',
      _ => 'application/octet-stream',
    };
  }

  LocalImage toEntity() => LocalImage(path: path, mimeType: mimeType, sizeInBytes: sizeInBytes);
}
