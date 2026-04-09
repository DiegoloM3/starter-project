import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/login/data/data_sources/remote/users_service.dart';
import 'package:news_app_clean_architecture/features/login/data/models/user.dart';

class UserServiceImpl implements UsersService {
  final _collection = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;

  @override
  Stream<UserModel?> get loginStream =>
      _auth.authStateChanges().asyncMap((user) async {
        if (user != null) {
          final userDoc = await _collection.doc(user.uid).get();

          if (userDoc.exists) {
            return UserModel.fromJson(
              map: userDoc.data()!,
              id: user.uid,
            );
          }
        }

        return null;
      });

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async =>
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  @override
  Future<void> signOut() async => await _auth.signOut();

  @override
  Future<void> createUser(UserModel user) async =>
      await _collection.doc(user.id.toString()).set(user.toJson());

  @override
  Future<String?> createCredentials({
    required String email,
    required String password,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.user?.uid;
  }
}
