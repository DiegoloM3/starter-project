import 'package:equatable/equatable.dart';

/// Entity representing a user in the application.
/// This is a pure business object with no dependencies on external frameworks.
class UserEntity extends Equatable {
  final String? id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        updatedAt,
      ];
}
