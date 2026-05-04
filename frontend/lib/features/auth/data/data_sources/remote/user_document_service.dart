import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

/// Abstract data source for Firestore `users/{uid}` document operations.
///
/// Only this file (and its impl) writes to `users/{uid}` (AV 1.2.3, design D4).
abstract class UserDocumentService {
  /// Creates or updates the `users/{uid}` document with merge semantics (NFR5).
  Future<void> upsertUser(AuthUserEntity user);
}
