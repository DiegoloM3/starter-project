/// The operation could not reach the backend.
///
/// It is the one failure every feature shares, which is why it lives in `core`
/// next to [DataState] rather than in one feature's domain: a repository in
/// `authentication` and one in `journalist_articles` both need to say it, and
/// neither may import the other.
///
/// Repositories raise it when the provider reports no connectivity, and when a
/// call spends longer than the data source is willing to wait. The two are the
/// same thing to the person holding the phone: the app could not talk to the
/// server, and trying again once they have signal is what will help.
class NetworkUnavailableException implements Exception {
  const NetworkUnavailableException();

  @override
  String toString() => 'NetworkUnavailableException()';
}
