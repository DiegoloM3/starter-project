import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Uploads article thumbnails to
/// `media/articles/{authorId}/{articleId}/{file}` — the exact path the
/// Storage rules whitelist. Returns the publicly-readable download URL.
class UserArticlesStorageDataSource {
  UserArticlesStorageDataSource(this._storage);

  final FirebaseStorage _storage;

  Future<String> uploadThumbnail({
    required String authorId,
    required String articleId,
    required String fileName,
    required List<int> bytes,
    required String contentType,
  }) async {
    final ref =
        _storage.ref('media/articles/$authorId/$articleId/$fileName');
    final task = ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: contentType),
    );
    final snapshot = await task;
    return snapshot.ref.getDownloadURL();
  }
}
