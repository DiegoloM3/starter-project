import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ArticlesStorageDataSource {
  final FirebaseStorage _storage;
  final Uuid _uuid;
  static const String _folder = 'media/articles';

  ArticlesStorageDataSource(this._storage, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  Future<String> uploadThumbnail(File file) async {
    final dotIndex = file.path.lastIndexOf('.');
    final ext =
        dotIndex >= 0 ? file.path.substring(dotIndex + 1).toLowerCase() : 'jpg';
    final safeExt = ext.isEmpty ? 'jpg' : ext;
    final filename = '${_uuid.v4()}.$safeExt';
    final ref = _storage.ref().child('$_folder/$filename');

    final metadata = SettableMetadata(
      contentType: _contentTypeFor(safeExt),
    );

    await ref.putFile(file, metadata);
    return ref.getDownloadURL();
  }

  String _contentTypeFor(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
