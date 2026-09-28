import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';

/// Data-layer view of [UserEntity] with Firebase/JSON parsing.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.isAnonymous,
  });

  /// Builds a model from Firebase Auth field values. The data source
  /// extracts these from the `firebase_auth` user so this model never
  /// imports provider packages (1.2.4).
  factory UserModel.fromAuth({
    required String uid,
    String email = '',
    String? displayName,
    String? photoUrl,
    bool isAnonymous = false,
  }) {
    return UserModel(
      id: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isAnonymous: isAnonymous,
    );
  }

  /// Builds a model from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isAnonymous': isAnonymous,
    };
  }

  /// Builds a model from a domain [entity].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      isAnonymous: entity.isAnonymous,
    );
  }

  /// Builds a model from external raw data.
  factory UserModel.fromRawData(Map<String, dynamic> raw) =>
      UserModel.fromJson(raw);

  /// Converts this model to its domain [UserEntity].
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isAnonymous: isAnonymous,
    );
  }
}
