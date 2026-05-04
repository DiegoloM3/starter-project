import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/user_document_service.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

/// Concrete implementation of [UserDocumentService] wrapping [FirebaseFirestore].
///
/// Uses `set(merge: true)` for idempotent upserts (NFR5).
class UserDocumentServiceImpl implements UserDocumentService {
  final FirebaseFirestore _firestore;

  UserDocumentServiceImpl(this._firestore);

  @override
  Future<void> upsertUser(AuthUserEntity user) async {
    await _firestore.collection('users').doc(user.uid).set(
      {
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'providerId': user.providerId,
        'isAnonymous': user.isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
