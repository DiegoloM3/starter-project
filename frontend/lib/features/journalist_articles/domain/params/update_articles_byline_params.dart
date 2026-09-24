/// Identifies the journalist whose byline is being rewritten, and what it is
/// being rewritten to.
class UpdateArticlesBylineParams {
  /// The author whose articles are rewritten. Nobody else's are touched, and
  /// `firestore.rules` would refuse them anyway.
  final String userId;

  /// The name readers should see from now on.
  final String authorName;

  const UpdateArticlesBylineParams({
    required this.userId,
    required this.authorName,
  });
}
