import 'package:equatable/equatable.dart';

enum UserRole {
  reader('reader'),
  journalist('journalist');

  final String id;

  const UserRole(this.id);

  /// Unknown roles fall back to reader, the role with the fewest permissions.
  static UserRole fromId(String id) {
    for (final role in values) {
      if (role.id == id) return role;
    }
    return reader;
  }
}

/// Public profile of a user.
class UserEntity extends Equatable {
  final String uid;
  final String firstName;
  final String lastName;
  final String bio;
  final String? photoURL;
  final UserRole role;

  const UserEntity({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.role,
    this.photoURL,
  });

  String get fullName => '$firstName $lastName';

  bool get canPublishArticles => role == UserRole.journalist;

  @override
  List<Object?> get props => [uid, firstName, lastName, bio, photoURL, role];
}
