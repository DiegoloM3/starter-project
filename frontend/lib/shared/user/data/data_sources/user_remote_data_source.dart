// UNICO lugar donde se importa Firestore y Auth para usuarios
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tortutip/shared/user/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<void> updateUserRole(String userId, String role);
  Future<void> selectUserCategories(String userId, List<String> categoryIds);
  Future<UserModel> updateUserProfile(UserModel user);
  Future<List<String>> getUserCategoryIds(String userId);
  Future<UserModel> getUserById(String userId);
  Future<UserModel> recordFeedSwipe(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRemoteDataSourceImpl(this._firestore, this._auth);

  @override
  Future<UserModel> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No hay usuario autenticado');
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromRawData({'id': doc.id, ...?doc.data()});
  }

  @override
  Future<void> updateUserRole(String userId, String role) async {
    await _firestore.collection('users').doc(userId).update({'role': role});
  }

  @override
  Future<void> selectUserCategories(String userId, List<String> categoryIds) async {
    final batch = _firestore.batch();
    final ref = _firestore.collection('user_categories');
    for (final id in categoryIds) {
      // ID compuesto = idempotente: misma combinación siempre sobrescribe el mismo doc
      batch.set(ref.doc('${userId}_$id'), {'user_id': userId, 'category_id': id});
    }
    await batch.commit();
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update({
      'name': user.name,
      'bio': user.bio,
      'avatar_url': user.avatarUrl,
    });
    return user;
  }

  @override
  Future<List<String>> getUserCategoryIds(String userId) async {
    final snapshot = await _firestore
        .collection('user_categories')
        .where('user_id', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['category_id'] as String)
        .toList();
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return UserModel.fromRawData({'id': doc.id, ...?doc.data()});
  }

  @override
  Future<UserModel> recordFeedSwipe(String userId) async {
    final docRef = _firestore.collection('users').doc(userId);
    late UserModel updated;
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = {'id': snap.id, ...?snap.data()};
      final today = _todayDate();
      final lastFeedDate = (data['last_feed_date'] as String?) ?? '';
      if (lastFeedDate == today) {
        updated = UserModel.fromRawData(data);
        return;
      }
      final yesterday = _offsetDate(today, -1);
      final currentStreak = (data['streak_days'] as int?) ?? 0;
      final newStreak = lastFeedDate == yesterday ? currentStreak + 1 : 1;
      final currentProgress =
          (data['overall_progress'] as num?)?.toDouble() ?? 0.0;
      final newProgress = (currentProgress + 0.01).clamp(0.0, 1.0);
      tx.update(docRef, {
        'streak_days': newStreak,
        'last_feed_date': today,
        'overall_progress': newProgress,
      });
      updated = UserModel.fromRawData({
        ...data,
        'streak_days': newStreak,
        'last_feed_date': today,
        'overall_progress': newProgress,
      });
    });
    return updated;
  }

  String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _offsetDate(String base, int offsetDays) {
    final parts = base.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    ).add(Duration(days: offsetDays));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
