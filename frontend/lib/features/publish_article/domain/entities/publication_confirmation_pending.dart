/// Persistence may still complete; this is neither failure nor success.
class PublicationConfirmationPending implements Exception {
  final String articleId;

  const PublicationConfirmationPending(this.articleId);
}
