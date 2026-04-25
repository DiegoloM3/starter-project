import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.displayName,
    super.email,
    super.isAnonymous,
  });

  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      displayName: firebaseUser.displayName,
      email: firebaseUser.email,
      isAnonymous: firebaseUser.isAnonymous,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      displayName: displayName,
      email: email,
      isAnonymous: isAnonymous,
    );
  }
}
