import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

/// Account of Firebase Authentication. Its display name is the journalist's name.
class UserModel extends UserEntity {
  const UserModel({required super.id, required super.name, required super.email});

  /// [rawData] holds the `id`, `name` and `email` of the account; an account can lack a name or an email.
  factory UserModel.fromRawData(Map<String, dynamic> rawData) {
    return UserModel(
      id: rawData['id'] as String,
      name: rawData['name'] as String? ?? '',
      email: rawData['email'] as String? ?? '',
    );
  }

  UserEntity toEntity() => UserEntity(id: id, name: name, email: email);
}
