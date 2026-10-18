import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/resources/exceptions.dart';
import '../../../../../core/resources/image_format.dart';

/// Profile photos in Cloud Storage, at `media/users/{uid}/{fileName}`.
class UserPhotoRemoteDataSource {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  UserPhotoRemoteDataSource(this._storage, this._auth, this._uuid);

  String get signedInUserId => _auth.currentUser?.uid ?? (throw const NotSignedInException());

  /// Returns the download URL. Every photo gets a new name, because the rules forbid overwriting.
  Future<String> uploadPhoto(String uid, Uint8List bytes) async {
    final format = ImageFormat.of(bytes);
    final file = _storage.ref('media/users/$uid/${_uuid.v4()}.${format.extension}');
    await file.putData(bytes, SettableMetadata(contentType: format.contentType));
    return file.getDownloadURL();
  }

  /// Best effort: a photo that cannot be deleted only takes some space, so errors are ignored.
  Future<void> deletePhoto(String photoURL) async {
    try {
      await _storage.refFromURL(photoURL).delete();
    } on Exception {
      return;
    }
  }
}
