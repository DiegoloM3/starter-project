import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';

/// Data-layer view of [UserProfileEntity] with Firestore JSON parsing.
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    super.displayName,
    super.photoUrl,
  });

  /// Builds a model from a Firestore JSON map.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  /// Builds a model from a domain [entity].
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
    );
  }

  /// Builds a model from external raw data.
  factory UserProfileModel.fromRawData(Map<String, dynamic> raw) =>
      UserProfileModel.fromJson(raw);

  /// Converts this model to its domain [UserProfileEntity].
  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
