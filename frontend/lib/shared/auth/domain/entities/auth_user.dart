class AuthUserEntity {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;

  const AuthUserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUserEntity &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          emailVerified == other.emailVerified;

  @override
  int get hashCode =>
      Object.hash(uid, email, displayName, photoUrl, emailVerified);
}
