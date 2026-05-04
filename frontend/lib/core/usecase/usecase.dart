abstract class UseCase<T, Params> {
  Future<T> call({Params? params});
}

/// Placeholder type for use cases that require no parameters.
class NoParams {
  const NoParams();
}
