import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/models/user_article_model.dart';

/// Abstract class defining the contract for article remote operations.
abstract class ArticleRemoteDataSource {
  /// Creates a new article in Firestore.
  Future<UserArticleModel> createArticle(UserArticleModel article);

  /// Updates an existing article in Firestore.
  Future<UserArticleModel> updateArticle(UserArticleModel article);

  /// Deletes an article from Firestore.
  Future<void> deleteArticle(String articleId);

  /// Gets a single article by its ID.
  Future<UserArticleModel?> getArticleById(String articleId);

  /// Gets all published articles (isDraft = false).
  Future<List<UserArticleModel>> getPublishedArticles();

  /// Gets all articles by a specific user.
  Future<List<UserArticleModel>> getUserArticles(String userId);

  /// Gets articles filtered by category.
  Future<List<UserArticleModel>> getArticlesByCategory(String category);

  /// Publishes a draft article.
  Future<UserArticleModel> publishArticle(String articleId);

  /// Unpublishes an article (converts to draft).
  Future<UserArticleModel> unpublishArticle(String articleId);
}

/// Implementation of ArticleRemoteDataSource using Firestore.
class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final FirebaseFirestore _firestore;

  ArticleRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to the articles collection.
  CollectionReference<Map<String, dynamic>> get _articlesCollection =>
      _firestore.collection('articles');

  @override
  Future<UserArticleModel> createArticle(UserArticleModel article) async {
    final now = DateTime.now();
    final articleToCreate = article.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    final docRef =
        await _articlesCollection.add(articleToCreate.toCreateJson());

    // Return the article with the generated ID
    return articleToCreate.copyWith(id: docRef.id);
  }

  @override
  Future<UserArticleModel> updateArticle(UserArticleModel article) async {
    if (article.id == null) {
      throw Exception('Article ID cannot be null for update');
    }

    final updatedArticle = article.copyWith(
      updatedAt: DateTime.now(),
    );

    await _articlesCollection.doc(article.id).update(updatedArticle.toJson());

    return updatedArticle;
  }

  @override
  Future<void> deleteArticle(String articleId) async {
    await _articlesCollection.doc(articleId).delete();
  }

  @override
  Future<UserArticleModel?> getArticleById(String articleId) async {
    final doc = await _articlesCollection.doc(articleId).get();

    if (!doc.exists) {
      return null;
    }

    return UserArticleModel.fromFirestore(doc);
  }

  @override
  Future<List<UserArticleModel>> getPublishedArticles() async {
    final querySnapshot = await _articlesCollection
        .where('isDraft', isEqualTo: false)
        .orderBy('publishedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => UserArticleModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<UserArticleModel>> getUserArticles(String userId) async {
    final querySnapshot = await _articlesCollection
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => UserArticleModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<UserArticleModel>> getArticlesByCategory(String category) async {
    final querySnapshot = await _articlesCollection
        .where('isDraft', isEqualTo: false)
        .where('categories', arrayContains: category)
        .orderBy('publishedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => UserArticleModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<UserArticleModel> publishArticle(String articleId) async {
    final now = DateTime.now();

    await _articlesCollection.doc(articleId).update({
      'isDraft': false,
      'publishedAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    final doc = await _articlesCollection.doc(articleId).get();
    return UserArticleModel.fromFirestore(doc);
  }

  @override
  Future<UserArticleModel> unpublishArticle(String articleId) async {
    final now = DateTime.now();

    await _articlesCollection.doc(articleId).update({
      'isDraft': true,
      'publishedAt': null,
      'updatedAt': Timestamp.fromDate(now),
    });

    final doc = await _articlesCollection.doc(articleId).get();
    return UserArticleModel.fromFirestore(doc);
  }
}
