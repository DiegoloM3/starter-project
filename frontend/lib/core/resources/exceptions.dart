/// The action requires a signed in user, such as saving, publishing or commenting.
class NotSignedInException implements Exception {
  const NotSignedInException();
}
