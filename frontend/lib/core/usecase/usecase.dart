/// A single business operation that completes once.
///
/// Implementations live in `domain/use_cases` and depend only on repository
/// interfaces. Use [NoParams] when the operation takes no input.
abstract interface class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// A business operation that keeps emitting values over time
/// (for example, the authentication state).
abstract interface class StreamUseCase<T, Params> {
  Stream<T> call(Params params);
}

/// Marker for use cases that take no input.
class NoParams {
  const NoParams();
}
