import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class FirebaseArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadArticle(ArticleModel article) async {
    try {
      await _firestore.collection('articles').add({
        'author': article.author,
        'title': article.title,
        'description': article.description,
        'url': article.url ?? "",
        'thumbnailURL': article.urlToImage ?? "",
        'publishedAt': FieldValue.serverTimestamp(),
        'content': article.content,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Overdelivery: method to fetch community uploaded articles
  Future<List<Map<String, dynamic>>> getUploadedArticles() async {
    final snapshot = await _firestore.collection('articles').orderBy('publishedAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}
