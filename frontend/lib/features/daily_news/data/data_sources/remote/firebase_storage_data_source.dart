import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource(this._storage);

  Future<String> uploadThumbnail({
    required String uid,
    required String articleId,
    required String filePath,
  }) async {
    final ref = _storage.ref('media/articles/$uid/$articleId/thumbnail');
    final file = File(filePath);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteThumbnail({
    required String uid,
    required String articleId,
  }) async {
    final ref = _storage.ref('media/articles/$uid/$articleId/thumbnail');
    await ref.delete();
  }
}
