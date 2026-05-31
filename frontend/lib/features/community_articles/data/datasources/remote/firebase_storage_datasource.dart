import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/errors/error_keys.dart';
import 'package:news_app_clean_architecture/core/errors/exceptions.dart';

/// Data source for Firebase Storage image operations.
///
/// This is the only class in the codebase that imports [firebase_storage].
@lazySingleton
class FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  static const String _basePath = 'community_article_images';

  FirebaseStorageDataSource(this._storage);

  /// Uploads [imageFile] for the given [userId] and returns the public download URL.
  ///
  /// Images are stored at: `community_article_images/{userId}/{timestamp}_{filename}`
  Future<String> uploadArticleImage(String userId, File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref('$_basePath/$userId/${timestamp}_$fileName');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: ServerErrorKeys.generic,
        statusCode: int.tryParse(e.code),
      );
    }
  }

  /// Deletes the image at the given [downloadUrl] from Firebase Storage.
  ///
  /// Silently ignores [FirebaseException] with code `object-not-found`
  /// to handle cases where the image was already deleted.
  Future<void> deleteImageByUrl(String downloadUrl) async {
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return;
      throw ServerException(
        message: ServerErrorKeys.generic,
        statusCode: int.tryParse(e.code),
      );
    }
  }
}
