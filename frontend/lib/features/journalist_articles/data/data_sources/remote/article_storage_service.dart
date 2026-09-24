import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';

import '../../../domain/entities/article_thumbnail.dart';

/// The only class in the app that talks to Cloud Storage.
///
/// Storage errors leave as [RemoteException] carrying the provider's code, so
/// the repository above never has to import the SDK (rule 1.2.4).
class ArticleStorageService {
  final FirebaseStorage _storage;

  const ArticleStorageService(this._storage);

  /// Uploads [thumbnail] into the folder owned by [userId] and returns its
  /// download URL.
  ///
  /// The path matches the one `backend/storage.rules` allows a user to write
  /// to (`media/articles/{userId}/...`); the file name is made unique so two
  /// covers picked from the same camera roll cannot overwrite each other.
  Future<String> uploadThumbnail({
    required String userId,
    required ArticleThumbnailEntity thumbnail,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}'
        '.${thumbnail.extension}';

    final reference =
        _storage.ref().child('$kArticleMediaFolder/$userId/$fileName');

    // Cloud Storage retries a failed upload on its own and keeps the task
    // alive across a network outage, so an upload started in airplane mode
    // never reports anything — it simply waits, and then completes minutes
    // later when signal comes back, long after the editor has moved on. The
    // task is held rather than just awaited so that giving up on it can also
    // stop it.
    final task = reference.putData(
      thumbnail.bytes,
      SettableMetadata(contentType: _contentTypeFor(thumbnail.extension)),
    );

    try {
      await task.timeout(kStorageTimeout);

      return await reference.getDownloadURL().timeout(kStorageTimeout);
    } on TimeoutException catch (error) {
      // Without this the abandoned upload finishes on its own and leaves a
      // file nothing points at, which is what made a cover appear as soon as
      // airplane mode was switched off.
      await task.cancel().catchError((_) => false);

      throw RemoteException(
        RemoteException.unavailableCode,
        message: 'Cloud Storage did not answer within $kStorageTimeout.',
        cause: error,
      );
    } on FirebaseException catch (error) {
      throw RemoteException(error.code, message: error.message, cause: error);
    }
  }

  /// Cloud Storage guesses `application/octet-stream` for raw bytes, which
  /// would stop the image from rendering in a browser.
  String _contentTypeFor(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
