import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around connectivity_plus -- the only file in this feature
/// that imports it, so the rest of the app depends on our own `Stream<bool>`
/// shape, not the plugin's list-of-results one.
class ConnectivityDataSource {
  final Connectivity _connectivity;

  ConnectivityDataSource(this._connectivity);

  Future<bool> checkConnectivity() async {
    return _isOnline(await _connectivity.checkConnectivity());
  }

  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  // Reports the OS-level radio state (attached to a wifi/cellular network),
  // not real internet reachability -- a wifi network with no internet (a
  // captive portal, a router with a dead uplink) still counts as "on".
  // Good enough for "did the connection just drop", which is all the
  // offline banner needs to know.
  bool _isOnline(List<ConnectivityResult> result) =>
      result.any((r) => r != ConnectivityResult.none);
}
