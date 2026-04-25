import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageDataSource {
  final FirebaseStorage _storage;

  StorageDataSource(this._storage);

  Future<String> uploadArticleThumbnail(
    String fileName,
    File imageFile,
  ) async {
    final ref = _storage.ref().child('media/articles/$fileName');

    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await ref.getDownloadURL();
  }

  Future<void> deleteArticleThumbnail(String thumbnailURL) async {
    try {
      final ref = _storage.refFromURL(thumbnailURL);
      await ref.delete();
    } catch (_) {
      // File may not exist, ignore
    }
  }
}
