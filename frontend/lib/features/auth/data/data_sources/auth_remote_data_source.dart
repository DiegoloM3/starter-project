// UNICO lugar donde se importa Firebase Auth y Google Sign-In
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  Future<UserEntity?> checkCurrentUser();
  Future<void> deleteCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._auth, this._googleSignIn, this._firestore);

  @override
  Future<UserEntity> signInWithGoogle() async {
    // google_sign_in 7.x: authenticate() reemplaza a signIn()
    final googleUser = await _googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'avatar_url': user.photoURL ?? '',
        'bio': '',
        'role': '',
        'gender': '',
        'age_range': '',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    final fresh = await _firestore.collection('users').doc(user.uid).get();
    final data = {'id': user.uid, ...?fresh.data()};
    return _toEntity(data);
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<UserEntity?> checkCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload(); // lanza si la cuenta fue eliminada
    final refreshed = _auth.currentUser;
    if (refreshed == null) return null;
    final doc = await _firestore.collection('users').doc(refreshed.uid).get();
    if (!doc.exists) return null;
    return _toEntity({'id': refreshed.uid, ...?doc.data()});
  }

  @override
  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay sesión activa');
    final uid = user.uid;

    // 1. Obtener todos los artículos del autor
    final articlesSnap = await _firestore
        .collection('articles')
        .where('author_id', isEqualTo: uid)
        .get();

    // 2. Para cada artículo, eliminar sus saved_articles y el artículo mismo
    for (final articleDoc in articlesSnap.docs) {
      final savedSnap = await _firestore
          .collection('saved_articles')
          .where('article_id', isEqualTo: articleDoc.id)
          .get();

      final batch = _firestore.batch();
      for (final saved in savedSnap.docs) {
        batch.delete(saved.reference);
      }
      batch.delete(articleDoc.reference);
      await batch.commit();
    }

    // 3. Eliminar los saved_articles donde el usuario guardó artículos de otros
    final userSavedSnap = await _firestore
        .collection('saved_articles')
        .where('user_id', isEqualTo: uid)
        .get();
    if (userSavedSnap.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (final doc in userSavedSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    // 4. Eliminar el documento del usuario y la cuenta Firebase Auth
    await _firestore.collection('users').doc(uid).delete();
    await user.delete();
  }

  UserEntity _toEntity(Map<String, dynamic> data) {
    return UserEntity(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatar_url'] ?? '',
      bio: data['bio'] ?? '',
      role: data['role'] ?? 'reader',
      gender: data['gender'] ?? '',
      ageRange: data['age_range'] ?? '',
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      streakDays: (data['streak_days'] as int?) ?? 0,
      lastFeedDate: (data['last_feed_date'] as String?) ?? '',
      overallProgress: (data['overall_progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
