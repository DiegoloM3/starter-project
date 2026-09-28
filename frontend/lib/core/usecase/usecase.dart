/// Single-operation business rule: executes via [call] against repository interfaces.
abstract interface class UseCase<T, Params> {
  /// Runs the operation with optional [params] and returns the result.
  Future<T> call({Params params});
}
