import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class UnsupportedImageFormatException implements Exception {
  final String extension;

  const UnsupportedImageFormatException(this.extension);

  @override
  String toString() => 'UnsupportedImageFormatException: .$extension images are not supported';
}

/// Stores the article thumbnails in the `media/articles` folder
/// (backend/docs/DB_SCHEMA.md).
class ArticleThumbnailStorageService {
  static const String thumbnailsFolder = 'media/articles';
  static const Map<String, String> contentTypesByExtension = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  final FirebaseStorage _storage;

  ArticleThumbnailStorageService(this._storage);

  /// Uploads the local image as the thumbnail of the article and returns its
  /// path in Cloud Storage.
  Future<String> uploadThumbnail(String articleId, String localImagePath) async {
    final extension = _readExtension(localImagePath);
    final contentType = contentTypesByExtension[extension];
    if (contentType == null) {
      throw UnsupportedImageFormatException(extension);
    }
    final thumbnailPath = '$thumbnailsFolder/$articleId.$extension';
    await _storage.ref(thumbnailPath).putFile(File(localImagePath), SettableMetadata(contentType: contentType));
    return thumbnailPath;
  }

  Future<String> getDownloadUrl(String thumbnailPath) {
    return _storage.ref(thumbnailPath).getDownloadURL();
  }

  String _readExtension(String path) {
    return path.split('.').last.toLowerCase();
  }
}
