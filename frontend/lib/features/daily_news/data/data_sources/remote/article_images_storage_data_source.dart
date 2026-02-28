import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ArticleImagesStorageDataSource {
  final FirebaseStorage _firebaseStorage;

  ArticleImagesStorageDataSource(this._firebaseStorage);

  Future<String> uploadArticleImage({
    required String authorId,
    required String localPath,
  }) async {
    final file = File(localPath);
    final extension = _fileExtension(localPath);
    final fileName = '${authorId}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final ref = _firebaseStorage
        .ref()
        .child('media')
        .child('articles')
        .child(fileName);

    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  String _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return path.substring(dotIndex);
  }
}
