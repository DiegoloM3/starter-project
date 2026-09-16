import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

/// A signed-in account as the identity provider describes it.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.displayName,
    super.photoUrl,
  });

  /// Blank strings from the provider count as absent.
  factory UserModel.fromRawData({
    required String id,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return UserModel(
      id: id,
      email: _presentOrNull(email),
      displayName: _presentOrNull(displayName),
      photoUrl: _presentOrNull(photoUrl),
    );
  }

  static String? _presentOrNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  UserEntity toEntity() =>
      UserEntity(id: id, email: email, displayName: displayName, photoUrl: photoUrl);
}
