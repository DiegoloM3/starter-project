import '../../domain/entities/app_user.dart';

/// Data layer view of [AppUserEntity].
///
/// It is built from plain Dart rather than from a Firebase `User`: the
/// provider's types stay inside `data/data_sources` (rule 1.2.4), which is
/// what hands this factory the map below.
class AppUserModel extends AppUserEntity {
  const AppUserModel({
    required super.id,
    required super.email,
    super.displayName,
  });

  /// Firebase leaves `email` and `displayName` null on an account created some
  /// other way. The entity promises strings, so this is where the nulls stop.
  factory AppUserModel.fromRawData(Map<String, dynamic> data) {
    return AppUserModel(
      id: data['uid'] as String? ?? '',
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
    );
  }

  AppUserEntity toEntity() {
    return AppUserEntity(id: id, email: email, displayName: displayName);
  }
}
