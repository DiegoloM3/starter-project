import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tortutip/features/articles/data/models/article_model.dart';
import 'package:tortutip/features/articles/domain/params/publish_article_params.dart';
import 'package:tortutip/features/articles/domain/params/update_article_params.dart';
import 'package:tortutip/features/articles/domain/params/upload_article_image_params.dart';

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getFeedArticles(List<String> categoryIds);
  Future<ArticleModel> getArticleDetail(String articleId);
  Future<ArticleModel> publishArticle(PublishArticleParams params);
  Future<void> saveArticle(String userId, String articleId);
  Future<List<ArticleModel>> getUserArticles(String userId);
  Future<List<String>> getSavedArticleIds(String userId);
  Future<List<ArticleModel>> getFeedArticlesPaged(List<String> categoryIds, int page, int pageSize);
  Future<void> unsaveArticle(String userId, String articleId);
  Future<List<ArticleModel>> getRelatedArticles(String categoryId, String excludeArticleId);
  Future<String> uploadArticleImage(UploadArticleImageParams params);
  Future<ArticleModel> updateArticle(UpdateArticleParams params);
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  ArticleRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<List<ArticleModel>> getFeedArticles(List<String> categoryIds) async {
    if (categoryIds.isEmpty) return [];
    final snapshot = await _firestore
        .collection('articles')
        .where('category_id', whereIn: categoryIds)
        .where('status', isEqualTo: 'published')
        .get();
    final docs = snapshot.docs
        .map((doc) => ArticleModel.fromRawData({'id': doc.id, ...doc.data()}))
        .toList();
    docs.sort((a, b) => (b.publishedAt ?? DateTime(0)).compareTo(a.publishedAt ?? DateTime(0)));
    return Future.wait(docs.map(_enrichWithAuthor));
  }

  @override
  Future<ArticleModel> getArticleDetail(String articleId) async {
    final doc =
        await _firestore.collection('articles').doc(articleId).get();
    final article = ArticleModel.fromRawData({'id': doc.id, ...?doc.data()});
    return _enrichWithAuthor(article);
  }

  @override
  Future<ArticleModel> publishArticle(PublishArticleParams params) async {
    final now = DateTime.now().toIso8601String();
    final data = {
      'author_id': params.authorId,
      'author_name': params.authorName,
      'author_avatar_url': params.authorAvatarUrl,
      'category_id': params.categoryId,
      'title': params.title,
      'body': params.body,
      'cover_vertical_url': params.coverVerticalUrl,
      'cover_horizontal_url': params.coverHorizontalUrl,
      'status': 'published',
      'read_time_minutes': params.readTimeMinutes,
      'save_count': 0,
      'published_at': now,
      'created_at': now,
    };
    final ref = await _firestore.collection('articles').add(data);
    return ArticleModel.fromRawData({'id': ref.id, ...data});
  }

  @override
  Future<void> saveArticle(String userId, String articleId) async {
    await _firestore
        .collection('saved_articles')
        .doc('${userId}_$articleId')
        .set({
      'user_id': userId,
      'article_id': articleId,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<ArticleModel>> getUserArticles(String userId) async {
    final snapshot = await _firestore
        .collection('articles')
        .where('author_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();
    final docs = snapshot.docs
        .map((doc) =>
            ArticleModel.fromRawData({'id': doc.id, ...doc.data()}))
        .toList();
    return Future.wait(docs.map(_enrichWithAuthor));
  }

  @override
  Future<List<String>> getSavedArticleIds(String userId) async {
    final snapshot = await _firestore
        .collection('saved_articles')
        .where('user_id', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['article_id'] as String)
        .toList();
  }

  @override
  Future<List<ArticleModel>> getFeedArticlesPaged(
      List<String> categoryIds, int page, int pageSize) async {
    final Query<Map<String, dynamic>> query;
    if (categoryIds.isEmpty) {
      query = _firestore
          .collection('articles')
          .where('status', isEqualTo: 'published');
    } else {
      query = _firestore
          .collection('articles')
          .where('category_id', whereIn: categoryIds)
          .where('status', isEqualTo: 'published');
    }
    final snapshot = await query.get();
    final raw = snapshot.docs
        .map((doc) => ArticleModel.fromRawData({'id': doc.id, ...doc.data()}))
        .toList();
    raw.sort((a, b) => (b.publishedAt ?? DateTime(0)).compareTo(a.publishedAt ?? DateTime(0)));
    final start = page * pageSize;
    if (start >= raw.length) return [];
    final end = (start + pageSize).clamp(0, raw.length);
    final page_ = raw.sublist(start, end);
    return Future.wait(page_.map(_enrichWithAuthor));
  }

  @override
  Future<void> unsaveArticle(String userId, String articleId) async {
    final snapshot = await _firestore
        .collection('saved_articles')
        .where('user_id', isEqualTo: userId)
        .where('article_id', isEqualTo: articleId)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<List<ArticleModel>> getRelatedArticles(
      String categoryId, String excludeArticleId) async {
    final snapshot = await _firestore
        .collection('articles')
        .where('category_id', isEqualTo: categoryId)
        .where('status', isEqualTo: 'published')
        .limit(6)
        .get();
    final docs = snapshot.docs
        .map((doc) => ArticleModel.fromRawData({'id': doc.id, ...doc.data()}))
        .where((a) => a.id != excludeArticleId)
        .take(5)
        .toList();
    return Future.wait(docs.map(_enrichWithAuthor));
  }

  @override
  Future<ArticleModel> updateArticle(UpdateArticleParams params) async {
    final ref = _firestore.collection('articles').doc(params.articleId);
    await ref.update({
      'category_id': params.categoryId,
      'title': params.title,
      'body': params.body,
      'cover_vertical_url': params.coverVerticalUrl,
      'cover_horizontal_url': params.coverHorizontalUrl,
      'read_time_minutes': params.readTimeMinutes,
    });
    final doc = await ref.get();
    final article = ArticleModel.fromRawData({'id': doc.id, ...?doc.data()});
    return _enrichWithAuthor(article);
  }

  Future<ArticleModel> _enrichWithAuthor(ArticleModel article) async {
    if (article.authorId.isEmpty) return article;
    try {
      final userDoc =
          await _firestore.collection('users').doc(article.authorId).get();
      final data = userDoc.data();
      if (data == null) return article;
      return ArticleModel(
        id: article.id,
        authorId: article.authorId,
        categoryId: article.categoryId,
        title: article.title,
        body: article.body,
        coverVerticalUrl: article.coverVerticalUrl,
        coverHorizontalUrl: article.coverHorizontalUrl,
        status: article.status,
        readTimeMinutes: article.readTimeMinutes,
        saveCount: article.saveCount,
        publishedAt: article.publishedAt,
        createdAt: article.createdAt,
        authorName: (data['name'] as String?) ?? '',
        authorAvatarUrl: (data['avatar_url'] as String?) ?? '',
      );
    } catch (_) {
      return article;
    }
  }

  @override
  Future<String> uploadArticleImage(UploadArticleImageParams params) async {
    final orientation = params.isVertical ? 'vertical' : 'horizontal';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref(
      'articles/${params.userId}/${timestamp}_$orientation.jpg',
    );
    final bytes = await params.imageFile.readAsBytes();
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }
}
