import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class FirestoreDatabaseService {
  final db = FirebaseFirestore.instance;
  // Collection Reference
  CollectionReference get articleFirestoreCollection =>
      db.collection("articles");

  Stream<QuerySnapshot> get articles {
    return articleFirestoreCollection.snapshots();
  }

  Future<List<ArticleModel>> getArticles() async {
    final snapshot = await articleFirestoreCollection.get();
    return snapshot.docs
        .map((doc) => ArticleModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  void addArticle(ArticleModel article) {
    articleFirestoreCollection.add({
      'author': article.author,
      'title': article.title,
      'description': article.description,
      'url_to_image': article.urlToImage,
      'published_at': article.publishedAt,
      'content': article.content
    });
  }
}
