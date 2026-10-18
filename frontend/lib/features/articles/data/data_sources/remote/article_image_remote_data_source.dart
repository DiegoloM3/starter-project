import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/resources/image_format.dart';

/// Images of the articles in Cloud Storage, at `media/articles/{fileName}`.
class ArticleImageRemoteDataSource {
  /// Value of the `role` custom claim that the Admin SDK gives to journalists.
  static const String _journalistRole = 'journalist';

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  ArticleImageRemoteDataSource(this._storage, this._auth, this._uuid);

  /// Returns the download URL. Every file gets a new random name, because the rules forbid overwriting.
  Future<String> uploadImage(Uint8List bytes) async {
    await _refreshRoleIfOutdated();
    final format = ImageFormat.of(bytes);
    final file = _storage.ref('media/articles/${_uuid.v4()}.${format.extension}');
    await file.putData(bytes, SettableMetadata(contentType: format.contentType));
    return file.getDownloadURL();
  }

  /// The rules trust the role in the token, which Firebase only refreshes every hour. A journalist
  /// promoted after signing in would be rejected until then, so the token is refreshed first.
  Future<void> _refreshRoleIfOutdated() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final token = await user.getIdTokenResult();
    if (token.claims?['role'] != _journalistRole) await user.getIdToken(true);
  }
}
