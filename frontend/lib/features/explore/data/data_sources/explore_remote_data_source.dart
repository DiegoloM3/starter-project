import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ExploreRemoteDataSource {
  Future<List<Map<String, dynamic>>> getArticlesByCategory(
    String categoryId,
    int page,
    int pageSize,
  );
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExploreRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<Map<String, dynamic>>> getArticlesByCategory(
    String categoryId,
    int page,
    int pageSize,
  ) async {
    final snapshot = await _firestore
        .collection('articles')
        .where('category_id', isEqualTo: categoryId)
        .where('status', isEqualTo: 'published')
        .get();

    final allMaps = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    return allMaps;
  }
}
