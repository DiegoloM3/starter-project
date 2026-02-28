import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';


class ArticlesFirestoreDataSource {
  final FirebaseFirestore _firestore;

  ArticlesFirestoreDataSource(this._firestore);

  Future<void> createArticle(ArticleModel article) async {
    await _firestore.collection('articles').add({
      'authorId': article.authorId,
      'author': article.author,
      'title': article.title,
      'description': article.description,
      'urlToImage': article.urlToImage,
      'content': article.content,
      'createdAt': FieldValue.serverTimestamp(),
      'publishedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ArticleModel>> getAllArticles() async {
    final querySnapshot = await _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ArticleModel.fromJson(doc.data(), documentId: doc.id))
        .toList();
  }

  Future<List<ArticleModel>> getArticlesByAuthor(String authorId) async {
    final querySnapshot = await _firestore
        .collection('articles')
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ArticleModel.fromJson(doc.data(), documentId: doc.id))
        .toList();
  }

  Future<void> deleteArticleById(String documentId) {
    return _firestore.collection('articles').doc(documentId).delete();
  }

  Future<void> deleteArticleByAuthorAndContent({
    required String authorId,
    required String title,
    String? description,
    String? content,
  }) async {
    final querySnapshot = await _firestore
        .collection('articles')
        .where('authorId', isEqualTo: authorId)
        .where('title', isEqualTo: title)
        .limit(20)
        .get();

    final normalizedDescription = description ?? '';
    final normalizedContent = content ?? '';

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final docDescription = (data['description'] ?? '').toString();
      final docContent = (data['content'] ?? '').toString();
      if (docDescription == normalizedDescription &&
          docContent == normalizedContent) {
        await doc.reference.delete();
        return;
      }
    }
  }
}
