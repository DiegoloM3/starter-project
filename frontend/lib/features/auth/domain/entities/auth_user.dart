import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated (or anonymous) Firebase user.
///
/// Contains only the auth-derived subset of user data. Profile fields
/// owned by other features (streaks, counters, timezone) belong to a
/// separate UserProfileEntity — see DB schema design D3.
///
/// Pure Dart — no Firebase or Flutter imports (AV 2.1.1).
class AuthUserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String providerId;
  final bool isAnonymous;

  const AuthUserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.providerId,
    required this.isAnonymous,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoURL,
        providerId,
        isAnonymous,
      ];
}
