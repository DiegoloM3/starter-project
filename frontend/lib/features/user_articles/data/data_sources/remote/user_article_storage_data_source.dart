import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Only class allowed to import firebase_storage for this feature
/// (ARCHITECTURE_VIOLATIONS.md Sec. 1.2.3/1.2.4).
class UserArticleStorageDataSource {
  final FirebaseStorage _storage;

  UserArticleStorageDataSource(this._storage);

  /// Uploads to media/articles/{articleId}.{extension} and returns the
  /// resolved download URL, per backend/docs/DB_SCHEMA.md's Storage
  /// convention. Stamped with [authorId] as custom metadata -- storage.rules
  /// reads it back to decide who may later replace this exact file, without
  /// a cross-service Firestore lookup (which, empirically, an overwrite of
  /// an existing file doesn't reliably trigger the right rule branch for).
  Future<String> uploadThumbnail({
    required String articleId,
    required Uint8List bytes,
    required String extension,
    required String authorId,
  }) async {
    final ref = _storage.ref('media/articles/$articleId.$extension');
    await ref.putData(
      bytes,
      SettableMetadata(customMetadata: {'authorId': authorId}),
    );
    return ref.getDownloadURL();
  }

  /// Deletes the file behind [downloadUrl]. A file that's already gone is
  /// what the caller wanted anyway, so that isn't an error.
  Future<void> deleteThumbnail(String downloadUrl) async {
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
