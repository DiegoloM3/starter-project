abstract class ConnectivityRepository {
  /// The device's connectivity: current value first, then every change.
  Stream<bool> watch();
}
