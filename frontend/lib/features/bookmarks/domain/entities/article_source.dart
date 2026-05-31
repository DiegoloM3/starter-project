/// Identifies the origin of a bookmarked article.
enum ArticleSource {
  /// Article fetched from the remote news API.
  api,

  /// Article created by a community user in Firestore.
  community,
}
