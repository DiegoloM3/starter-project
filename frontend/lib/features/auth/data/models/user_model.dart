import '../../domain/entities/user.dart';

/// Public profile stored in `users/{uid}`.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.firstName,
    required super.lastName,
    required super.bio,
    required super.role,
    super.photoURL,
  });

  /// Missing fields get the values of a new reader, so an incomplete document cannot break the app.
  factory UserModel.fromRawData(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      photoURL: data['photoURL'] as String?,
      role: UserRole.fromId(data['role'] as String? ?? ''),
    );
  }

  UserEntity toEntity() {
    return UserEntity(uid: uid, firstName: firstName, lastName: lastName, bio: bio, photoURL: photoURL, role: role);
  }
}
