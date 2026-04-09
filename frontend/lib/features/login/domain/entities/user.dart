import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? profilePictureUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.profilePictureUrl,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        profilePictureUrl,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePictureUrl,
  }) =>
      UserEntity(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      );
}
