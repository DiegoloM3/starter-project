import 'package:news_app_clean_architecture/features/login/data/models/user.dart';

abstract class UsersService {
  Future<String?> createCredentials({
    required String email,
    required String password,
  });
  Future<void> createUser(UserModel user);
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Stream<UserModel?> get loginStream;
}
