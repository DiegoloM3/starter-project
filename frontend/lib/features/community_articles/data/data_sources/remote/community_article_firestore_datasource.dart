import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

import 'community_article_remote_datasource.dart';

class CommunityArticleFirestoreDataSource
    implements CommunityArticleRemoteDataSource {
  static const _collection = 'articles';

  final FirebaseFirestore _firestore;

  CommunityArticleFirestoreDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _articlesRef =>
      _firestore.collection(_collection);

  @override
  Stream<List<ArticleEntity>> watchArticles() {
    return _articlesRef
        .orderBy('publishedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_docToEntity).toList());
  }

  @override
  Future<String> publishArticle(ArticleEntity article) async {
    final docRef = await _articlesRef.add({
      'uid': article.uid ?? 'anonymous',
      'title': article.title,
      'description': article.description,
      'content': article.content,
      'imageUrl': article.urlToImage,
      'publishedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  ArticleEntity _docToEntity(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['publishedAt'];
    final publishedAt = ts is Timestamp ? ts.toDate().toIso8601String() : null;
    return ArticleEntity(
      firestoreId: doc.id,
      uid: data['uid'] as String?,
      title: data['title'] as String?,
      description: data['description'] as String?,
      content: data['content'] as String?,
      urlToImage: data['imageUrl'] as String?,
      publishedAt: publishedAt,
    );
  }
}
