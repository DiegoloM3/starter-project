import 'package:firebase_auth/firebase_auth.dart';

/// Thrown when trying to publish, comment or save an article while nobody is signed in.
class NoSignedInJournalistException implements Exception {
  const NoSignedInJournalistException();
}

/// The author fields of a new article or comment: the ID and the name of the signed-in account,
/// the only ones the security rules accept.
Map<String, dynamic> readAuthorOfSignedInJournalist(FirebaseAuth auth) {
  final journalist = auth.currentUser;
  if (journalist == null) throw const NoSignedInJournalistException();
  return {'author': journalist.displayName ?? '', 'authorId': journalist.uid};
}

/// The uid of the signed-in account, which owns the journalist's lists (for example, the saved articles).
String readSignedInJournalistId(FirebaseAuth auth) {
  final journalist = auth.currentUser;
  if (journalist == null) throw const NoSignedInJournalistException();
  return journalist.uid;
}
