import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class FirebaseDataSource {
  final FirebaseFirestore _firestore;

  FirebaseDataSource(this._firestore);

  Future<List<ArticleModel>> getArticles() async {
    final snapshot = await _firestore
        .collection('articles')
        .orderBy('publishedAt', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => ArticleModel.fromRawData(doc.data())).toList();
  }

  Future<void> postArticle(ArticleModel article) async {
    await _firestore
        .collection('articles')
        .doc(article.articleId)
        .set(article.toRawData());
  }
}
