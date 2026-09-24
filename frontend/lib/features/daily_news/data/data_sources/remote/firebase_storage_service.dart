import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseStorageService {
  Future<String> uploadThumbnail(
    File file,
    String articleId, {
    void Function(int, int)? onProgress,
  });
  Future<void> deleteThumbnail(String articleId);
  Future<String> getDownloadUrl(String articleId);
}

class FirebaseStorageServiceImpl implements FirebaseStorageService {
  final FirebaseStorage _storage;
  static const String _thumbnailPath = 'media/articles';

  FirebaseStorageServiceImpl(this._storage);

  @override
  Future<String> uploadThumbnail(
    File file,
    String articleId, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      final path = '$_thumbnailPath/$articleId/thumbnail';
      final ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded_by': 'user'},
      );
      final uploadTask = ref.putFile(file, metadata);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((event) {
          onProgress(event.bytesTransferred, event.totalBytes);
        });
      }

      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload thumbnail: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload thumbnail: $e');
    }
  }

  @override
  Future<void> deleteThumbnail(String articleId) async {
    try {
      final path = '$_thumbnailPath/$articleId/thumbnail';
      final ref = _storage.ref().child(path);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete thumbnail: ${e.message}');
    }
  }

  @override
  Future<String> getDownloadUrl(String articleId) async {
    try {
      final path = '$_thumbnailPath/$articleId/thumbnail';
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get download URL: ${e.message}');
    }
  }
}
