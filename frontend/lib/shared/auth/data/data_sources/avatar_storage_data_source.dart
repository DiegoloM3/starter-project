import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/exceptions/auth_exceptions.dart';

class AvatarUploadRequest {
  final List<int> bytes;
  final String fileName;
  const AvatarUploadRequest({required this.bytes, required this.fileName});
}

class AvatarStorageDataSource {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  AvatarStorageDataSource(this._storage, this._auth);

  static const _rootFolder = 'media/users';

  Future<String> uploadAvatarForCurrentUser(AvatarUploadRequest request) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthUnknownException('Not signed in.');
    try {
      final ext = _extensionOf(request.fileName);
      final ref = _storage.ref('$_rootFolder/${user.uid}/avatar$ext');
      await ref.putData(
        Uint8List.fromList(request.bytes),
        SettableMetadata(contentType: _contentTypeFor(ext)),
      );
      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw AuthUnknownException(e.message ?? e.code);
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
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
