/// A domain-level failure type for article errors.
/// Stored in [DataFailed.error.error] throughout the articles feature.
class ArticleFailure {
  final String message;

  const ArticleFailure(this.message);

  @override
  String toString() => message;
}
