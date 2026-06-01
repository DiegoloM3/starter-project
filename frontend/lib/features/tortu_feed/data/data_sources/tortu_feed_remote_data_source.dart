import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TortuFeedRemoteDataSource {
  Future<void> feedTortu({
    required String userId,
    required String articleId,
    required String categoryId,
    required String date,
  });

  Future<bool> checkTodayTip({required String userId, required String date});

  Future<double> updateCategoryProgress({
    required String userId,
    required String categoryId,
  });

  Future<double> getCategoryProgress({
    required String userId,
    required String categoryId,
  });

  Future<int> getStreakDays({required String userId});

  Future<double> getOverallProgress({required String userId});
}

class TortuFeedRemoteDataSourceImpl implements TortuFeedRemoteDataSource {
  final FirebaseFirestore _firestore;

  TortuFeedRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> feedTortu({
    required String userId,
    required String articleId,
    required String categoryId,
    required String date,
  }) async {
    await _firestore
        .collection('daily_tips')
        .doc('${userId}_$date')
        .set({
      'id': '${userId}_$date',
      'user_id': userId,
      'article_id': articleId,
      'category_id': categoryId,
      'date': date,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> checkTodayTip({
    required String userId,
    required String date,
  }) async {
    final doc = await _firestore
        .collection('daily_tips')
        .doc('${userId}_$date')
        .get();
    return doc.exists;
  }

  @override
  Future<double> updateCategoryProgress({
    required String userId,
    required String categoryId,
  }) async {
    final docRef = _firestore
        .collection('user_category_progress')
        .doc('${userId}_$categoryId');

    double newProgress = 0.01;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {
          'id': '${userId}_$categoryId',
          'user_id': userId,
          'category_id': categoryId,
          'progress': 0.01,
          'tips_count': 1,
          'updated_at': FieldValue.serverTimestamp(),
        });
        newProgress = 0.01;
      } else {
        final current = (snapshot.data()!['progress'] as num).toDouble();
        newProgress = (current + 0.01).clamp(0.0, 1.0);
        transaction.update(docRef, {
          'progress': newProgress,
          'tips_count': (snapshot.data()!['tips_count'] as int) + 1,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    });

    return newProgress;
  }

  @override
  Future<double> getCategoryProgress({
    required String userId,
    required String categoryId,
  }) async {
    final doc = await _firestore
        .collection('user_category_progress')
        .doc('${userId}_$categoryId')
        .get();
    if (!doc.exists) return 0.0;
    return (doc.data()!['progress'] as num).toDouble();
  }

  @override
  Future<int> getStreakDays({required String userId}) async {
    final snapshot = await _firestore
        .collection('daily_tips')
        .where('user_id', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return 0;

    final dates = snapshot.docs
        .map((d) => d.data()['date'] as String?)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // desc

    final today = _todayDate();
    if (dates.first != today) return 0; // streak roto

    int streak = 1;
    for (int i = 1; i < dates.length; i++) {
      final expected = _offsetDate(today, -i);
      if (dates[i] == expected) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Future<double> getOverallProgress({required String userId}) async {
    final snapshot = await _firestore
        .collection('user_category_progress')
        .where('user_id', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final total = snapshot.docs.fold<double>(
      0.0,
      (acc, doc) => acc + (doc.data()['progress'] as num).toDouble(),
    );
    return (total / snapshot.docs.length).clamp(0.0, 1.0);
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
