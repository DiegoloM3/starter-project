// coverage:ignore-file
// Thin wrapper over the Cloud Storage SDK.
// Covered by the repository tests above it, with the SDK mocked at this seam.
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Uploads and deletes images in Cloud Storage (article thumbnails and
/// profile photos). Errors propagate as [FirebaseException]s.
class ImageStorageService {
  final FirebaseStorage _storage;

  ImageStorageService(this._storage);

  /// Uploads the file at [filePath] to [objectPath] and returns the download
  /// URL. The content type is stored so the Storage rules can check it.
  Future<String> upload({
    required String filePath,
    required String objectPath,
    required String contentType,
  }) async {
    final reference = _storage.ref(objectPath);
    await reference.putFile(File(filePath), SettableMetadata(contentType: contentType));
    return reference.getDownloadURL();
  }

  Future<void> delete(String objectPath) => _storage.ref(objectPath).delete();
}
