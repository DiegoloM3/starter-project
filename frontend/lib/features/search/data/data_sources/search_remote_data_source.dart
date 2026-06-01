import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tortutip/features/articles/data/models/article_model.dart';
import 'package:tortutip/features/categories/data/models/category_model.dart';
import 'package:tortutip/shared/user/data/models/user_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<ArticleModel>> searchArticles(String query);
  Future<List<CategoryModel>> searchCategories(String query);
  Future<List<UserModel>> searchCreators(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final FirebaseFirestore _firestore;

  SearchRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<ArticleModel>> searchArticles(String query) async {
    // Firestore no soporta substring search — filtramos en cliente
    final snapshot = await _firestore
        .collection('articles')
        .where('status', isEqualTo: 'published')
        .get();

    final q = query.toLowerCase();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ArticleModel.fromRawData(data);
        })
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.body.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<CategoryModel>> searchCategories(String query) async {
    final snapshot = await _firestore.collection('categories').get();

    final q = query.toLowerCase();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return CategoryModel.fromRawData(data);
        })
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<UserModel>> searchCreators(String query) async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'writer')
        .get();

    final q = query.toLowerCase();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return UserModel.fromRawData(data);
        })
        .where((u) => u.name.toLowerCase().contains(q))
        .take(10)
        .toList();
  }
}
