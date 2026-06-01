import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tortutip/features/categories/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getAllCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore _firestore;
  CategoryRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs
        .map((doc) =>
            CategoryModel.fromRawData({'id': doc.id, ...doc.data()}))
        .toList();
  }
}
