/// The Firestore collections of the journalists' articles (backend/docs/DB_SCHEMA.md).
abstract final class FirestorePaths {
  static const String articles = 'articles';

  /// Subcollection of each article.
  static const String comments = 'comments';

  static const String users = 'users';

  /// Subcollection of each user.
  static const String savedArticles = 'savedArticles';
}
