/// Lifecycle state of an article written by a journalist.
///
/// The values mirror the `status` field enforced by `backend/firestore.rules`,
/// which only accepts `"draft"` or `"published"`.
enum ArticleStatus { draft, published }

extension ArticleStatusValue on ArticleStatus {
  /// Value used to persist the status and to query it on the backend.
  ///
  /// Parsing raw backend data back into an [ArticleStatus] is the
  /// responsibility of the data layer models, not of the business layer.
  String get value {
    switch (this) {
      case ArticleStatus.draft:
        return 'draft';
      case ArticleStatus.published:
        return 'published';
    }
  }
}
