import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/exceptions/upload_article_exceptions.dart';

class ThumbnailUploadRequest {
  final String articleId;
  final List<int> bytes;
  final String fileName;

  const ThumbnailUploadRequest({
    required this.articleId,
    required this.bytes,
    required this.fileName,
  });
}

class UploadedThumbnail {
  final String path;
  final String downloadUrl;

  const UploadedThumbnail({required this.path, required this.downloadUrl});
}

class StorageArticleDataSource {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  StorageArticleDataSource(this._storage, this._auth);

  static const _rootFolder = 'media/articles';

  Future<UploadedThumbnail> uploadThumbnailForCurrentUser(
      ThumbnailUploadRequest request) async {
    final user = _auth.currentUser;
    if (user == null) throw const UnauthenticatedException();
    final ext = _extensionOf(request.fileName);
    final path = '$_rootFolder/${user.uid}/${request.articleId}/thumbnail$ext';
    try {
      final ref = _storage.ref(path);
      await ref.putData(
        Uint8List.fromList(request.bytes),
        SettableMetadata(contentType: _contentTypeFor(ext)),
      );
      final url = await ref.getDownloadURL();
      return UploadedThumbnail(path: path, downloadUrl: url);
    } on FirebaseException catch (e) {
      throw UploadFailedException(e.message ?? e.code);
    }
  }

  Future<void> deleteByPath(String path) async {
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        throw UploadFailedException(e.message ?? e.code);
      }
    }
  }

  String _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) return '.jpg';
    return fileName.substring(dot).toLowerCase();
  }

  String _contentTypeFor(String ext) {
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
