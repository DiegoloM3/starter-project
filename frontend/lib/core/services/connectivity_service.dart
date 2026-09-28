
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  factory ConnectivityService() => _instance;
  static final ConnectivityService _instance = ConnectivityService._internal();
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onStatusChange {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}