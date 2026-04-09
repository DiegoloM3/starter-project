import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.profilePictureUrl,
  });

  factory UserModel.fromJson({
    required Map<String, dynamic> map,
    required String id,
  }) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      profilePictureUrl: entity.profilePictureUrl,
    );
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        name: name,
        profilePictureUrl: profilePictureUrl,
      );

  Map<String, dynamic> toJson() => {
        //! If your are using Firebase Firestore,
        //! do not add id here, it will be used as document id
        'email': email,
        'name': name,
        'profilePictureUrl': profilePictureUrl,
      };
}
