import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_profile.model.dart';

/// Firestore/Storage data source for public user profiles at `users/{uid}`.
@injectable
class UserProfileFirebaseService {
  static final _log = Logger('UserProfileFirebaseService');

  final FirebaseFirestore _firestoreDb = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _usersCollection = kUsersCollection;

  /// Creates the public profile document at `users/{uid}`.
  Future<void> createUserProfile(UserProfileModel profile) async {
    _log.info(
        'createUserProfile → creating profile for user ${profile.id}');
    await _firestoreDb
        .collection(_usersCollection)
        .doc(profile.id)
        .set(profile.toJson());
  }

  /// Returns the public profile for [userId], or null when it is blank or
  /// the document does not exist (e.g. accounts predating profiles).
  Future<UserProfileModel?> getUserProfile(String userId) async {
    if (userId.trim().isEmpty) return null;

    final doc = await _firestoreDb
        .collection(_usersCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return UserProfileModel.fromJson(doc.data()!);
  }

  /// Uploads [imageFile] under `media/avatars/[userId]` and returns its
  /// download URL. Returns null if [imageFile] is null.
  Future<String?> uploadAvatar(String userId, File? imageFile) async {
    if (imageFile == null) return null;

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.uri.pathSegments.last}';
    final ref = _storage.ref().child('$kAvatarsFolder/$userId/$fileName');

    _log.info('uploadAvatar → uploading avatar for user $userId');
    final task = await ref.putFile(imageFile);
    final url = await task.ref.getDownloadURL();
    _log.info('uploadAvatar → uploaded, url=$url');
    return url;
  }

  /// Writes [profile] with merge semantics, so it also backfills accounts
  /// that predate the `users` collection.
  Future<void> saveUserProfile(UserProfileModel profile) async {
    _log.info('saveUserProfile → saving profile for user ${profile.id}');
    await _firestoreDb.collection(_usersCollection).doc(profile.id).set(
          profile.toJson(),
          SetOptions(merge: true),
        );
  }
}
